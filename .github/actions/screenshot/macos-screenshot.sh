#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${1:?app binary name is required}"
OUTPUT_FILE="${2:?output filename is required}"

echo "Starting macOS window screenshot process for $APP_NAME"

# Launch the application (assume executable name = process name)
echo "Launching application: ./$APP_NAME"
"./$APP_NAME" &
APP_PID=$!
trap 'kill "$APP_PID" 2>/dev/null || true' EXIT
echo "Application launched with PID: $APP_PID"

# Find the on-screen window id used by screencapture -l.
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

for _ in 0..<90 {
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
      id: windowID
    ))
  }

  if let best = candidates.sorted(by: {
    if $0.layer == $1.layer {
      return $0.area > $1.area
    }
    return $0.layer < $1.layer
  }).first {
    print(best.id)
    exit(0)
  }

  Thread.sleep(forTimeInterval: 0.5)
}

print("ERROR: CoreGraphics window not found")
exit(1)
SWIFT

  swiftc get_cg_window_info.swift -o get_cg_window_info
fi

echo "Waiting for window to appear..."
WINDOW_ID=$(./get_cg_window_info "$APP_NAME" "$APP_PID") || {
  echo "$WINDOW_ID"
  exit 1
}
echo "Window id: $WINDOW_ID"
echo "Capturing with screencapture -l $WINDOW_ID -> $OUTPUT_FILE"
screencapture -x -t png -l"$WINDOW_ID" "$OUTPUT_FILE"
ls -la "$OUTPUT_FILE"

echo "macOS window screenshot process completed successfully"
