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

# Wait for application startup
sleep 3

# Wait for the window to appear
echo "Waiting for window to appear..."
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

if [ "$EXISTS" != "true" ] || [ "$HAS_WIN" != "true" ]; then
  echo "ERROR: process or window not found"
  osascript -e 'tell application "System Events" to get name of every process' | tr "," "\n" | head -50
  # Fallback: full screen capture
  screencapture -x "$OUTPUT_FILE"
  exit 0
fi

# Write AppleScript to a temporary file to avoid heredoc issues
cat > get_rect.applescript <<'OSA'
tell application "System Events"
  tell process "APP_NAME_PLACEHOLDER"
    set frontmost to true
    delay 0.5
    if (count of windows) = 0 then return "ERROR: no windows"
    set win to window 1
    set {xPos, yPos} to position of win
    set {wSize, hSize} to size of win
    set AppleScript's text item delimiters to ","
    return {xPos, yPos, wSize, hSize} as text
  end tell
end tell
OSA

# Replace placeholder with actual app name
sed -i '' "s/APP_NAME_PLACEHOLDER/$APP_NAME/g" get_rect.applescript

# Get window rect as x,y,w,h
RECT=$(osascript get_rect.applescript)
case "$RECT" in
  ERROR:*) echo "$RECT"; screencapture -x "$OUTPUT_FILE"; exit 0 ;;
esac

# Remove whitespace and validate format
RECT=$(echo "$RECT" | tr -d '[:space:]')
if ! [[ "$RECT" =~ ^[0-9]+,[0-9]+,[0-9]+,[0-9]+$ ]]; then
  echo "ERROR: invalid rect: '$RECT'"
  screencapture -x "$OUTPUT_FILE"
  exit 0
fi
echo "Window rect: $RECT"

# Check screencapture permission (TCC/GUI)
if ! screencapture -x /tmp/_probe.png 2>/dev/null; then
  echo "Screen capture likely not permitted on hosted macOS runner (no GUI/TCC)."
  screencapture -x "$OUTPUT_FILE"
  exit 0
fi

# Capture the window region
echo "Capturing with screencapture -R $RECT -> $OUTPUT_FILE"
screencapture -x -t png -R "$RECT" "$OUTPUT_FILE"
ls -la "$OUTPUT_FILE"

echo "macOS window screenshot process completed successfully"
