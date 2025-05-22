@echo off
setlocal enabledelayedexpansion

:: Application configuration
set APP_NAME=md5checker
set APP_NAME_CAPITALIZED=Md5checker
set EXECUTABLE_PATH=bin\%APP_NAME%.exe
set DIST_DIR=dist
set INSTALLER_NAME=%APP_NAME%-setup.exe
set ISS_FILE=%APP_NAME%.iss
set OUTPUT_DIR=Output

:: Inno Setup compiler path - try to find it automatically or use default locations
set ISCC=ISCC.exe

:: Check if ISCC is in PATH
where %ISCC% >nul 2>&1
if %ERRORLEVEL% neq 0 (
  :: Try common installation paths
  if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    set ISCC="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
  ) else if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
    set ISCC="C:\Program Files\Inno Setup 6\ISCC.exe"
  ) else if exist "%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe" (
    set ISCC="%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe"
  ) else (
    echo Warning: Inno Setup not found in common locations.
    echo Please ensure Inno Setup is installed and either:
    echo 1. Add Inno Setup directory to your PATH, or
    echo 2. Modify the ISCC variable in this script with the full path to ISCC.exe
    echo Example: set ISCC="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    exit /b 1
  )
)

echo Using Inno Setup compiler: %ISCC%

:: --- Step 1: Install dependencies and build the application ---
echo Installing dependencies...
call shards install

echo Building application with release optimizations...
call shards build --release

:: --- Step 2: Initialize directories ---
echo Cleaning up previous builds...
if exist %DIST_DIR% (
  rd /s /q %DIST_DIR%
)
if exist %OUTPUT_DIR% (
  rd /s /q %OUTPUT_DIR%
)
md %DIST_DIR%
md %OUTPUT_DIR%

:: --- Step 3: Create Inno Setup script ---
echo Creating Inno Setup script...
echo [Setup] > %ISS_FILE%
echo AppName=%APP_NAME_CAPITALIZED% >> %ISS_FILE%
echo AppVersion=1.0 >> %ISS_FILE%
echo DefaultDirName={userpf}\%APP_NAME_CAPITALIZED% >> %ISS_FILE%
echo DefaultGroupName=%APP_NAME_CAPITALIZED% >> %ISS_FILE%
echo OutputDir=%OUTPUT_DIR% >> %ISS_FILE%
echo OutputBaseFilename=%APP_NAME%-setup >> %ISS_FILE%
echo Compression=lzma >> %ISS_FILE%
echo SolidCompression=yes >> %ISS_FILE%
echo PrivilegesRequired=lowest >> %ISS_FILE%
echo PrivilegesRequiredOverridesAllowed=commandline >> %ISS_FILE%
echo DisableDirPage=no >> %ISS_FILE%
echo DisableProgramGroupPage=no >> %ISS_FILE%
echo. >> %ISS_FILE%
echo [Files] >> %ISS_FILE%
echo Source: "%EXECUTABLE_PATH%"; DestDir: "{app}"; Flags: ignoreversion >> %ISS_FILE%
echo Source: "README.md"; DestDir: "{app}"; Flags: isreadme ignoreversion >> %ISS_FILE%
echo. >> %ISS_FILE%
echo [Tasks] >> %ISS_FILE%
echo Name: "desktopicon"; Description: "Create a desktop icon"; GroupDescription: "Additional icons:"; Flags: unchecked >> %ISS_FILE%
echo. >> %ISS_FILE%
echo [Icons] >> %ISS_FILE%
echo Name: "{group}\%APP_NAME_CAPITALIZED%"; Filename: "{app}\%APP_NAME%.exe" >> %ISS_FILE%
echo Name: "{group}\Uninstall %APP_NAME_CAPITALIZED%"; Filename: "{uninstallexe}" >> %ISS_FILE%
echo Name: "{commondesktop}\%APP_NAME_CAPITALIZED%"; Filename: "{app}\%APP_NAME%.exe"; Tasks: desktopicon >> %ISS_FILE%
echo. >> %ISS_FILE%
echo [Run] >> %ISS_FILE%
echo Filename: "{app}\%APP_NAME%.exe"; Description: "Launch %APP_NAME_CAPITALIZED%"; Flags: nowait postinstall skipifsilent >> %ISS_FILE%

:: --- Step 4: Build installer with Inno Setup ---
echo Building installer with Inno Setup...
%ISCC% %ISS_FILE%

:: --- Step 5: Collect artifacts in dist/ directory ---
echo Moving artifacts to dist/ directory...
copy %EXECUTABLE_PATH% %DIST_DIR%\ 2>nul
copy %ISS_FILE% %DIST_DIR%\ 2>nul

if exist %OUTPUT_DIR%\%INSTALLER_NAME% (
  move %OUTPUT_DIR%\%INSTALLER_NAME% %DIST_DIR%\
)

:: --- Step 6: Clean up temporary files ---
echo Cleaning up temporary files...
rd /s /q %OUTPUT_DIR%
del %ISS_FILE% 2>nul

:: --- Complete ---
echo.
echo Build completed! Artifacts:
dir %DIST_DIR% 2>nul

echo.
echo Distribution file: dist\%INSTALLER_NAME%
