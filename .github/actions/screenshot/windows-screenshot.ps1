param(
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputFile
)

Write-Host "Starting Windows window screenshot process for $AppName"

# Add Win32 API definitions
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Drawing;

public class Win32 {
    [DllImport("user32.dll")]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    
    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);
    
    [DllImport("user32.dll")]
    public static extern IntPtr GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    
    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);
    
    [DllImport("user32.dll")]
    public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);
    
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    
    public const int SW_RESTORE = 9;
    public const int SW_SHOW = 5;
}

[StructLayout(LayoutKind.Sequential)]
public struct RECT {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
}
"@

try {
    # Launch the application
    $process = Start-Process -FilePath ".\$AppName" -PassThru
    Write-Host "Application launched with PID: $($process.Id)"

    # Wait for application to fully load
    Start-Sleep -Seconds 5

    # Find the main window for the process
    $mainWindow = $null
    $processId = $process.Id
    
    # Enumerate windows to find the one belonging to our process
    $callback = {
        param($hWnd, $lParam)
        
        $windowProcessId = 0
        [Win32]::GetWindowThreadProcessId($hWnd, [ref]$windowProcessId)
        
        if ($windowProcessId -eq $processId -and [Win32]::IsWindowVisible($hWnd)) {
            $windowTitle = New-Object System.Text.StringBuilder 256
            [Win32]::GetWindowText($hWnd, $windowTitle, 256)
            
            if ($windowTitle.Length -gt 0) {
                $titleString = $windowTitle.ToString()
                Write-Host "Found window: $titleString (Handle: $hWnd)"
                
                # Prioritize GUI application windows over console windows
                # Look for windows that don't end with .exe (console windows typically do)
                if ($titleString -notlike "*.exe") {
                    Write-Host "Selecting GUI window: $titleString"
                    $script:mainWindow = $hWnd
                    return $false  # Stop enumeration
                }
                elseif ($script:mainWindow -eq $null) {
                    # Only use console window as fallback if no GUI window found yet
                    Write-Host "Fallback window candidate: $titleString"
                    $script:mainWindow = $hWnd
                }
            }
        }
        return $true  # Continue enumeration
    }
    
    [Win32]::EnumWindows($callback, [IntPtr]::Zero)
    
    if ($mainWindow -eq $null) {
        Write-Warning "Could not find main window for process. Falling back to screen capture."
        
        # Fallback to full screen capture
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        
        $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
        $bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
    }
    else {
        Write-Host "Capturing window with handle: $mainWindow"
        
        # Bring window to foreground
        [Win32]::ShowWindow($mainWindow, [Win32]::SW_RESTORE)
        [Win32]::SetForegroundWindow($mainWindow)
        Start-Sleep -Seconds 1
        
        # Get window rectangle
        $rect = New-Object RECT
        if ([Win32]::GetWindowRect($mainWindow, [ref]$rect)) {
            $width = $rect.Right - $rect.Left
            $height = $rect.Bottom - $rect.Top
            
            Write-Host "Window bounds: Left=$($rect.Left), Top=$($rect.Top), Width=$width, Height=$height"
            
            # Capture the window area
            Add-Type -AssemblyName System.Windows.Forms
            Add-Type -AssemblyName System.Drawing
            
            $bitmap = New-Object System.Drawing.Bitmap $width, $height
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, [System.Drawing.Size]::new($width, $height))
        }
        else {
            Write-Warning "Could not get window rectangle. Falling back to screen capture."
            
            # Fallback to full screen capture
            $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
            $bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
        }
    }

    # Save as PNG
    $bitmap.Save($OutputFile, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "Screenshot saved to: $OutputFile"

    # Cleanup graphics objects
    $graphics.Dispose()
    $bitmap.Dispose()

    # Stop the application
    Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    Write-Host "Application process terminated"

    # Verify screenshot was created
    if (Test-Path $OutputFile) {
        Write-Host "Screenshot created successfully"
        Get-Item $OutputFile | Format-List Name, Length, LastWriteTime
    } else {
        Write-Error "Failed to create screenshot"
        exit 1
    }

    Write-Host "Windows window screenshot process completed successfully"
}
catch {
    Write-Error "Error during screenshot process: $($_.Exception.Message)"
    
    # Cleanup: try to stop the process if it's still running
    if ($process -and !$process.HasExited) {
        try {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
            Write-Host "Cleaned up application process"
        }
        catch {
            Write-Warning "Could not clean up application process: $($_.Exception.Message)"
        }
    }
    
    exit 1
}
