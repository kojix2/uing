#!/bin/bash
set -e

APP_NAME="$1"
OUTPUT_FILE="$2"

echo "Starting Ubuntu window screenshot process for $APP_NAME"

# Start Xvfb with proper screen resolution
Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset & 
echo $! > xvfb.pid
sleep 3

# Start window manager
openbox --config-file /dev/null & 
echo $! > wm.pid
sleep 2

# Launch the application in background
./$APP_NAME & 
echo $! > app.pid

# Wait for application to fully load
sleep 5

# Try to find the application window by PID
WINDOW_ID=""
ATTEMPTS=0
MAX_ATTEMPTS=10
APP_PID=$(cat app.pid)

echo "Searching for window belonging to PID: $APP_PID"

while [ -z "$WINDOW_ID" ] && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    # Try to find any window belonging to our process
    for wid in $(wmctrl -l | awk '{print $1}'); do
        # Try to get window PID
        WIN_PID=$(xprop -id "$wid" _NET_WM_PID 2>/dev/null | awk '{print $3}' || true)
        if [ "$WIN_PID" = "$APP_PID" ]; then
            WINDOW_ID="$wid"
            # Get window title for logging
            WINDOW_TITLE=$(xprop -id "$wid" WM_NAME 2>/dev/null | cut -d'"' -f2 || echo "Unknown")
            echo "Found window ID: $WINDOW_ID with title: $WINDOW_TITLE for PID: $APP_PID"
            break
        fi
    done
    
    if [ -z "$WINDOW_ID" ]; then
        echo "Attempt $((ATTEMPTS + 1)): Window not found yet, waiting..."
        sleep 1
        ATTEMPTS=$((ATTEMPTS + 1))
    fi
done

if [ -n "$WINDOW_ID" ]; then
    echo "Found window with ID: $WINDOW_ID"
    
    # Focus the window
    wmctrl -i -a "$WINDOW_ID" || true
    sleep 1
    
    # Take screenshot of the specific window
    import -window "$WINDOW_ID" -display :99 "$OUTPUT_FILE"
    
    echo "Window screenshot captured successfully"
else
    echo "Warning: Could not find application window, falling back to root window screenshot"
    
    # Fallback: Take screenshot of the entire screen
    import -window root -display :99 "$OUTPUT_FILE"
    
    echo "Root window screenshot captured as fallback"
fi

# Verify screenshot was created
if [ -f "$OUTPUT_FILE" ]; then
    echo "Screenshot created successfully: $OUTPUT_FILE"
    file "$OUTPUT_FILE"
    
    # Get image dimensions for verification
    identify "$OUTPUT_FILE" || true
else
    echo "Failed to create screenshot"
    exit 1
fi

# Cleanup function
cleanup() {
    echo "Cleaning up processes..."
    # Kill processes in reverse order
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
