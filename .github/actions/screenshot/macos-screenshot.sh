#!/bin/bash
set -e

APP_NAME="$1"
OUTPUT_FILE="$2"

echo "Starting macOS screenshot process for $APP_NAME"

# Launch the application in background
./$APP_NAME &
APP_PID=$!
echo "Application launched with PID: $APP_PID"

# Wait for application to fully load
sleep 5

# Function to verify process is running
verify_process() {
    local app_pid="$1"
    
    echo "Verifying process PID: $app_pid"
    
    if ps -p "$app_pid" > /dev/null 2>&1; then
        echo "Process $app_pid is running"
        
        # Get process details for debugging
        ps -p "$app_pid" -o pid,ppid,comm,args || true
        
        return 0
    else
        echo "Process $app_pid is not running"
        return 1
    fi
}

# Function to wait for GUI initialization
wait_for_gui() {
    local app_pid="$1"
    local max_wait=15
    local waited=0
    
    echo "Waiting for GUI initialization (max ${max_wait}s)..."
    
    while [ $waited -lt $max_wait ]; do
        if verify_process "$app_pid"; then
            # Additional wait for GUI elements to be ready
            sleep 2
            echo "GUI should be ready after ${waited}s + 2s buffer"
            return 0
        fi
        
        echo "Waiting... (${waited}s/${max_wait}s)"
        sleep 1
        waited=$((waited + 1))
    done
    
    echo "Timeout waiting for GUI initialization"
    return 1
}

# Verify the process is running and wait for GUI
if wait_for_gui "$APP_PID"; then
    echo "Process verified, taking full screen screenshot..."
    
    # Simple full screen capture
    screencapture -x -t png "$OUTPUT_FILE" 2>/dev/null || {
        echo "Screen capture failed"
        exit 1
    }
    
    echo "Screenshot captured successfully"
    
else
    echo "Process verification failed, attempting emergency screen capture..."
    
    # Emergency fallback
    screencapture -x -t png "$OUTPUT_FILE" 2>/dev/null || {
        echo "Emergency screen capture failed"
        exit 1
    }
    
    echo "Emergency screen capture completed"
fi

# Verify screenshot was created
if [ -f "$OUTPUT_FILE" ]; then
    echo "Screenshot created successfully: $OUTPUT_FILE"
    file "$OUTPUT_FILE" || true
    
    # Get image dimensions for verification
    if command -v sips > /dev/null; then
        sips -g pixelWidth -g pixelHeight "$OUTPUT_FILE" || true
    fi
else
    echo "Failed to create screenshot"
    exit 1
fi

# Cleanup: kill the application
if [ -n "$APP_PID" ]; then
    echo "Cleaning up application process (PID: $APP_PID)..."
    kill $APP_PID 2>/dev/null || true
    
    # Wait a moment and force kill if necessary
    sleep 2
    kill -9 $APP_PID 2>/dev/null || true
fi

echo "macOS screenshot process completed successfully"
