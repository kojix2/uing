#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${1:?app binary name is required}"
OUTPUT_FILE="${2:?output filename is required}"

echo "Starting macOS window screenshot process for $APP_NAME"

# Cleanup function to kill the app process
cleanup() {
  echo "Cleaning up processes..."
  if [ -f app.pid ]; then
    APP_PID=$(cat app.pid)
    echo "Killing application process (PID: $APP_PID)..."
    kill "$APP_PID" 2>/dev/null || true
    rm -f app.pid
  fi
}
trap cleanup EXIT INT TERM

# Launch the application (assume executable name = process name)
echo "Launching application: ./$APP_NAME"
"./$APP_NAME" &
APP_PID=$!
echo $APP_PID > app.pid
echo "Application launched with PID: $APP_PID"

# CoreGraphics can expose the window id used by screencapture -l even when
# Accessibility does not provide AXWindowNumber on GitHub-hosted runners.
if [ ! -x get_cg_window_info ]; then
  cat > get_cg_window_info.swift <<'SWIFT'
import CoreGraphics
import Foundation

let appName = CommandLine.arguments[1]
let appPid = Int(CommandLine.arguments[2]) ?? 0

struct Candidate {
  let layer: Int
  let area: Int
  let id: Int
  let x: Int
  let y: Int
  let width: Int
  let height: Int
}

func intValue(_ value: Any?) -> Int {
  if let number = value as? NSNumber {
    return number.intValue
  }
  if let int = value as? Int {
    return int
  }
  if let double = value as? Double {
    return Int(double)
  }
  return 0
}

func doubleValue(_ value: Any?, default defaultValue: Double = 0) -> Double {
  if let number = value as? NSNumber {
    return number.doubleValue
  }
  if let double = value as? Double {
    return double
  }
  if let int = value as? Int {
    return Double(int)
  }
  return defaultValue
}

for _ in 0..<30 {
  let info = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[String: Any]] ?? []
  var candidates: [Candidate] = []

  for window in info {
    let ownerPid = intValue(window[kCGWindowOwnerPID as String])
    let ownerName = window[kCGWindowOwnerName as String] as? String ?? ""
    if ownerPid != appPid && ownerName != appName {
      continue
    }

    let bounds = window[kCGWindowBounds as String] as? [String: Any] ?? [:]
    let width = intValue(bounds["Width"])
    let height = intValue(bounds["Height"])
    let windowID = intValue(window[kCGWindowNumber as String])
    let alpha = doubleValue(window[kCGWindowAlpha as String], default: 1)
    if width <= 1 || height <= 1 || windowID <= 0 || alpha <= 0 {
      continue
    }

    candidates.append(Candidate(
      layer: intValue(window[kCGWindowLayer as String]),
      area: width * height,
      id: windowID,
      x: intValue(bounds["X"]),
      y: intValue(bounds["Y"]),
      width: width,
      height: height
    ))
  }

  if let best = candidates.sorted(by: {
    if $0.layer == $1.layer {
      return $0.area > $1.area
    }
    return $0.layer < $1.layer
  }).first {
    print("\(best.id),\(best.x),\(best.y),\(best.width),\(best.height)")
    exit(0)
  }

  Thread.sleep(forTimeInterval: 0.5)
}

print("ERROR: CoreGraphics window not found")
exit(1)
SWIFT

  swiftc get_cg_window_info.swift -o get_cg_window_info
fi

# Wait for application startup
sleep 3

# Write AppleScript to a temporary file to avoid heredoc issues.
# AXWindowNumber is the CoreGraphics window id used by screencapture -l, but
# some GitHub-hosted macOS images do not expose it for every Accessibility
# window. Keep the bounds so region capture can still produce an artifact.
cat > get_window_info.applescript <<'OSA'
tell application "System Events"
  tell process "APP_NAME_PLACEHOLDER"
    set frontmost to true
    delay 1.0
    if (count of windows) = 0 then return "ERROR: no windows"
    set win to window 1
    set windowNumber to "missing"
    try
      set axWindowNumber to value of attribute "AXWindowNumber" of win
      if axWindowNumber is not missing value then set windowNumber to axWindowNumber as text
    end try
    set {xPos, yPos} to position of win
    set {wSize, hSize} to size of win
    set AppleScript's text item delimiters to ","
    return {windowNumber, xPos, yPos, wSize, hSize} as text
  end tell
end tell
OSA

# Replace placeholder with actual app name
sed -i '' "s/APP_NAME_PLACEHOLDER/$APP_NAME/g" get_window_info.applescript

# Get window id and rect as id,x,y,w,h
echo "Waiting for window to appear..."
WINDOW_INFO=$(./get_cg_window_info "$APP_NAME" "$APP_PID" || true)
if [[ "$WINDOW_INFO" == ERROR:* ]] || [ -z "$WINDOW_INFO" ]; then
  echo "$WINDOW_INFO"
  echo "CoreGraphics lookup failed; trying Accessibility window lookup."
  for i in {1..20}; do
    EXISTS=$(osascript -e "tell application \"System Events\" to return exists process \"$APP_NAME\"" || true)
    if [ "$EXISTS" = "true" ]; then
      HAS_WIN=$(osascript -e "tell application \"System Events\" to tell process \"$APP_NAME\" to return (count of windows) > 0" || true)
      if [ "$HAS_WIN" = "true" ]; then
        break
      fi
    fi
    sleep 0.5
  done

  if [ "${EXISTS:-false}" != "true" ] || [ "${HAS_WIN:-false}" != "true" ]; then
    echo "ERROR: process or window not found"
    osascript -e 'tell application "System Events" to get name of every process' | tr "," "\n" | head -50
    # Fallback: full screen capture
    screencapture -x "$OUTPUT_FILE"
    exit 0
  fi

  WINDOW_INFO=$(osascript get_window_info.applescript)
fi
case "$WINDOW_INFO" in
  ERROR:*) echo "$WINDOW_INFO"; screencapture -x "$OUTPUT_FILE"; exit 0 ;;
esac

# Remove whitespace and validate format
WINDOW_INFO=$(echo "$WINDOW_INFO" | tr -d '[:space:]')
if ! [[ "$WINDOW_INFO" =~ ^(missing|[0-9]+),-?[0-9]+,-?[0-9]+,[0-9]+,[0-9]+$ ]]; then
  echo "ERROR: invalid window info: '$WINDOW_INFO'"
  screencapture -x "$OUTPUT_FILE"
  exit 0
fi
WINDOW_ID="${WINDOW_INFO%%,*}"
RECT="${WINDOW_INFO#*,}"
echo "Window id: $WINDOW_ID"
echo "Window rect: $RECT"

if [ "$WINDOW_ID" = "missing" ]; then
  echo "AXWindowNumber is unavailable; falling back to region capture."
  screencapture -x -t png -R "$RECT" "$OUTPUT_FILE"
else
  # Capture the target window by id. Unlike region capture, this avoids other
  # windows such as macOS permission prompts being burned into the image.
  echo "Capturing with screencapture -l $WINDOW_ID -> $OUTPUT_FILE"
  if ! screencapture -x -t png -l"$WINDOW_ID" "$OUTPUT_FILE"; then
    echo "Window-id capture failed; falling back to region capture."
    screencapture -x -t png -R "$RECT" "$OUTPUT_FILE"
  fi
fi
ls -la "$OUTPUT_FILE"

echo "macOS window screenshot process completed successfully"
