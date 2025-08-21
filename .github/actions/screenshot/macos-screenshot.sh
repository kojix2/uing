#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${1:?app binary name is required}"
OUTPUT_FILE="${2:?output filename is required}"

echo "Starting macOS window screenshot process for $APP_NAME"

# ---- temp workspace ---------------------------------------------------------
TMPDIR="$(mktemp -d)"
SWIFT_FILE="$TMPDIR/get_window.swift"
WININFO_JSON="$TMPDIR/windows.json"
PROBE_IMG="$TMPDIR/_probe.png"
echo "(tmp: $TMPDIR)"

cleanup() {
  echo "Cleaning up..."
  if [[ -f "$TMPDIR/app.pid" ]]; then
    APP_PID="$(cat "$TMPDIR/app.pid" || true)"
    [[ -n "${APP_PID:-}" ]] && kill "$APP_PID" 2>/dev/null || true
  fi
  rm -rf "$TMPDIR" || true
}
trap cleanup EXIT INT TERM

# ---- launch app -------------------------------------------------------------
launch_app() {
  if [[ -x "./$APP_NAME" ]]; then
    echo "Launching local binary: ./$APP_NAME"
    "./$APP_NAME" &
    sleep 0.2
  elif [[ "$APP_NAME" == *.app ]] || osascript -e "id of app \"$APP_NAME\"" >/dev/null 2>&1; then
    echo "Launching via: open -a $APP_NAME"
    open -a "$APP_NAME" --fresh || open -a "$APP_NAME"
  else
    echo "Launching as path (fallback): ./$APP_NAME"
    "./$APP_NAME" &
    sleep 0.2
  fi
}
launch_app
# NOTE: if we launched via 'open -a', $! is the PID of 'open', not the app.
APP_PID=$!
echo "$APP_PID" > "$TMPDIR/app.pid"
echo "Application launched with PID: $APP_PID"

# ---- wait for process & bring to front -------------------------------------
for i in $(seq 1 40); do
  if pgrep -f -- "$APP_NAME" >/dev/null 2>&1; then
    break
  fi
  sleep 0.25
done
# If launched via 'open -a', resolve the real app PID for cleanup
REAL_PID="$(pgrep -f -- "$APP_NAME" 2>/dev/null | awk 'NR==1{print $1}')"
if [[ -n "${REAL_PID:-}" ]]; then
  echo "$REAL_PID" > "$TMPDIR/app.pid"
fi

osascript -e "ignoring application responses
  tell application \"$APP_NAME\" to activate
end ignoring" >/dev/null 2>&1 || true
sleep 1

# ---- Swift helper: pick window id (layer 0, largest area) ------------------
cat > "$SWIFT_FILE" <<'SWIFT'
import Foundation, CoreGraphics

struct Win {
  let ownerName: String
  let windowNumber: Int
  let ownerPID: Int
  let layer: Int
  let isOnscreen: Bool
  let bounds: CGRect
}

func listWins() -> [Win] {
  let opts: CGWindowListOption = [.excludeDesktopElements, .optionOnScreenOnly]
  guard let info = CGWindowListCopyWindowInfo(opts, kCGNullWindowID) as? [[String: Any]] else { return [] }
  return info.compactMap { d in
    guard let owner = d[kCGWindowOwnerName as String] as? String,
          let num   = d[kCGWindowNumber as String] as? Int,
          let pid   = d[kCGWindowOwnerPID as String] as? Int,
          let layer = d[kCGWindowLayer as String] as? Int,
          let b     = d[kCGWindowBounds as String] as? [String: CGFloat] else { return nil }
    let rect = CGRect(x: b["X"] ?? 0, y: b["Y"] ?? 0, width: b["Width"] ?? 0, height: b["Height"] ?? 0)
    let on = (d[kCGWindowIsOnscreen as String] as? Bool) ?? true
    return Win(ownerName: owner, windowNumber: num, ownerPID: pid, layer: layer, isOnscreen: on, bounds: rect)
  }
}

func area(_ r: CGRect) -> CGFloat { r.width * r.height }

let args = CommandLine.arguments
// usage: swift wait.swift <OwnerName> <TimeoutSec> <PollIntervalSec> [OwnerPID]
guard args.count >= 4 else { exit(2) }
let owner = args[1].lowercased()
let timeout = Double(args[2]) ?? 5.0
let interval = max(0.02, Double(args[3]) ?? 0.10)
let ownerPID: Int? = (args.count >= 5) ? Int(args[4]) : nil
let deadline = Date().addingTimeInterval(timeout)

while Date() < deadline {
  let all = listWins().filter { $0.layer == 0 && $0.isOnscreen }
  let pidFiltered = ownerPID != nil ? all.filter { $0.ownerPID == ownerPID } : all
  let exact = pidFiltered.filter { $0.ownerName.lowercased() == owner }
  let soft  = pidFiltered.filter { $0.ownerName.lowercased().contains(owner) }
  let pick = (exact.max { area($0.bounds) < area($1.bounds) }) ??
             (soft.max  { area($0.bounds) < area($1.bounds) })
  if let p = pick {
    let b = p.bounds
    print("\(p.windowNumber),\(Int(b.origin.x)),\(Int(b.origin.y)),\(Int(b.size.width)),\(Int(b.size.height))")
    exit(0)
  }
  Thread.sleep(forTimeInterval: interval)
}
exit(1)
SWIFT

# ---- wait window & get id/rect ---------------------------------------------
echo "Waiting for window (CGWindowList)…"
# 例: タイムアウト 5s / ポーリング 0.10s。必要ならここを短縮可。
WINLINE="$(/usr/bin/swift "$SWIFT_FILE" "$APP_NAME" 5.0 0.10 "${REAL_PID:-}" 2>/dev/null || true)"

if [[ ! "$WINLINE" =~ ^([0-9]+),([-0-9]+),([-0-9]+),([0-9]+),([0-9]+)$ ]]; then
  echo "Window not found. Dump (top):"
  # （JSONダンプは廃止。必要ならここで追加ログを出してください）
  echo "Fallback: full-screen capture"
  screencapture -x "$OUTPUT_FILE" || true
  exit 0
fi

WIN_ID="${BASH_REMATCH[1]}"
RECT="${BASH_REMATCH[2]},${BASH_REMATCH[3]},${BASH_REMATCH[4]},${BASH_REMATCH[5]}"
echo "Found window id: $WIN_ID (rect: $RECT)"

# ---- PRIMARY: capture by window id (no overlay) ----------------------------
echo "Capturing via window id: screencapture -x -t png -l $WIN_ID"
screencapture -x -t png -l "$WIN_ID" "$OUTPUT_FILE" || true
if [[ ! -s "$OUTPUT_FILE" ]]; then
  sleep 0.4
  screencapture -x -t png -l "$WIN_ID" "$OUTPUT_FILE" || true
fi
# ---- TCC probe (only if -l failed) -----------------------------------------
if [[ ! -s "$OUTPUT_FILE" ]]; then
  if ! screencapture -x "$PROBE_IMG" 2>/dev/null; then
    echo "Screen capture not permitted (TCC). Fallback to full-screen."
    screencapture -x "$OUTPUT_FILE" || true
    exit 0
  fi
  # try once more after permission
  screencapture -x -t png -l "$WIN_ID" "$OUTPUT_FILE" || true
fi

# ---- FALLBACKS: region -> full ---------------------------------------------
if [[ ! -s "$OUTPUT_FILE" ]]; then
  echo "WARN: -l failed; trying -R $RECT"
  screencapture -x -t png -R "$RECT" "$OUTPUT_FILE" || true
fi

if [[ ! -s "$OUTPUT_FILE" ]]; then
  echo "WARN: -R failed; taking full-screen"
  screencapture -x "$OUTPUT_FILE" || true
fi

ls -la "$OUTPUT_FILE" 2>/dev/null || true
echo "Done."
