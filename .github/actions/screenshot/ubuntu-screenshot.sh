#!/bin/bash
set -e

APP_NAME="$1"
OUTPUT_FILE="$2"

echo "Starting Ubuntu window screenshot process for $APP_NAME"

# Start Xvfb with proper screen resolution
Xvfb :99 -screen 0 1280x800x24 -ac +extension GLX +render -noreset &
echo $! > xvfb.pid
sleep 3

# Ensure all X clients use the same display
export DISPLAY=:99
echo "Using DISPLAY=$DISPLAY"

# Start window manager (avoid --config-file /dev/null to suppress syntax error dialog)
openbox &
echo $! > wm.pid
sleep 2

# Launch the application in background
"./$APP_NAME" &
echo $! > app.pid

# Short initial wait; loop below will wait for the window anyway
sleep 1

# Try to find the application window by PID
WINDOW_ID=""
ATTEMPTS=0
MAX_ATTEMPTS=10
APP_PID=$(cat app.pid)

echo "Searching for window belonging to PID: $APP_PID"

# Helper: try to find a window by matching PID via wmctrl -lp
find_window_by_pid() {
  local pids="$1"
  wmctrl -lp 2>/dev/null | awk -v pids="$pids" '
    BEGIN {
      n = split(pids, a, /[ \t]+/);
      for (i = 1; i <= n; i++) if (a[i] != "") wanted[a[i]] = 1;
    }
    $3 in wanted { print $1; exit }
  ' | head -n1
}

# Helper: collect immediate child PIDs (in case the window is owned by a child process)
collect_child_pids() {
  local root="$1"
  local list="$root"
  local kids
  kids="$(pgrep -P "$root" 2>/dev/null || true)"
  if [ -n "$kids" ]; then
    list="$list $kids"
  fi
  echo "$list"
}

while [ -z "$WINDOW_ID" ] && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
  CANDIDATE_PIDS="$(collect_child_pids "$APP_PID")"

  # 1) Fast path: use wmctrl -lp to match PID column
  WINDOW_ID="$(find_window_by_pid "$CANDIDATE_PIDS" || true)"

  # 2) Fallback: scan windows and read _NET_WM_PID via xprop
  if [ -z "$WINDOW_ID" ]; then
    for wid in $(wmctrl -l 2>/dev/null | awk '{print $1}'); do
      WIN_PID="$(xprop -id "$wid" _NET_WM_PID 2>/dev/null | awk '{print $3}' || true)"
      for p in $CANDIDATE_PIDS; do
        if [ -n "$WIN_PID" ] && [ "$WIN_PID" = "$p" ]; then
          WINDOW_ID="$wid"
          break
        fi
      done
      [ -n "$WINDOW_ID" ] && break
    done
  fi

  if [ -z "$WINDOW_ID" ]; then
    echo "Attempt $((ATTEMPTS + 1))/$MAX_ATTEMPTS: Window not found yet, waiting..."
    sleep 1
    ATTEMPTS=$((ATTEMPTS + 1))
  fi
done

if [ -n "$WINDOW_ID" ]; then
  echo "Found window with ID: $WINDOW_ID"
  WINDOW_TITLE="$(xprop -id "$WINDOW_ID" WM_NAME 2>/dev/null | cut -d'"' -f2 || echo "Unknown")"
  echo "Window title: $WINDOW_TITLE"

  # Focus the window
  wmctrl -i -a "$WINDOW_ID" || true
  sleep 1

# Take screenshot incl. window decorations (title bar)
import -frame -window "$WINDOW_ID" "$OUTPUT_FILE"

  echo "Window screenshot captured successfully"
else
  echo "Warning: Could not find application window, falling back to root window screenshot"

  # Fallback: Take screenshot of the entire screen
  import -window root "$OUTPUT_FILE"

  echo "Root window screenshot captured as fallback"
fi

# Verify screenshot was created
if [ -f "$OUTPUT_FILE" ]; then
  echo "Screenshot created successfully: $OUTPUT_FILE"
  file "$OUTPUT_FILE"
  identify "$OUTPUT_FILE" || true
else
  echo "Failed to create screenshot"
  exit 1
fi

# Cleanup function
cleanup() {
  echo "Cleaning up processes..."
  if [ -f app.pid ]; then
    kill $(cat app.pid) 2>/dev/null || true
    rm -f app.pid
  fi
  if [ -f wm.pid ]; then
    kill $(cat wm.pid) 2>/dev/null || true
    rm -f wm.pid
  fi
  if [ -f xvfb.pid ]; then
    kill $(cat xvfb.pid) 2>/dev/null || true
    rm -f xvfb.pid
  fi
}

# Set trap to cleanup on exit
trap cleanup EXIT

echo "Ubuntu window screenshot process completed successfully"
