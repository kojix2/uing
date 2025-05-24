# PowerShell script for building Windows installer

$ErrorActionPreference = "Stop"

# Load configuration from .env
Get-Content .env | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]*)=(.*)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim('"')
        Set-Variable -Name $name -Value $value -Scope Global
    }
}

$EXECUTABLE_PATH = "bin\$APP_NAME.exe"
$DIST_DIR = "dist"
$INSTALLER_NAME = "$APP_NAME-setup.exe"
$ISS_FILE = "$APP_NAME.iss"
$OUTPUT_DIR = "Output"

# Use Inno Setup compiler from configuration
$ISCC = $INNO_SETUP_PATH
if (-not (Get-Command $ISCC -ErrorAction SilentlyContinue)) {
    Write-Error "Error: Inno Setup not found at '$ISCC'. Please set INNO_SETUP_PATH in .env file or environment variable."
    Write-Host "Example: INNO_SETUP_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    exit 1
}

Write-Host "Building $APP_NAME v$VERSION..."
& shards install
& shards build --release --no-debug --link-flags=/SUBSYSTEM:WINDOWS

if (Test-Path $DIST_DIR) { Remove-Item $DIST_DIR -Recurse -Force }
if (Test-Path $OUTPUT_DIR) { Remove-Item $OUTPUT_DIR -Recurse -Force }
New-Item -ItemType Directory -Path $DIST_DIR | Out-Null
New-Item -ItemType Directory -Path $OUTPUT_DIR | Out-Null

# Create Inno Setup script using here-string
$issContent = @"
[Setup]
AppName=$APP_NAME_CAPITALIZED
AppVersion=$VERSION
DefaultDirName={userpf}\$APP_NAME_CAPITALIZED
DefaultGroupName=$APP_NAME_CAPITALIZED
OutputDir=$OUTPUT_DIR
OutputBaseFilename=$APP_NAME-setup
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest

[Files]
Source: "$EXECUTABLE_PATH"; DestDir: "{app}"; Flags: ignoreversion
Source: "README.md"; DestDir: "{app}"; Flags: isreadme ignoreversion

[Icons]
Name: "{group}\$APP_NAME_CAPITALIZED"; Filename: "{app}\$APP_NAME.exe"
Name: "{group}\Uninstall $APP_NAME_CAPITALIZED"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\$APP_NAME.exe"; Description: "Launch $APP_NAME_CAPITALIZED"; Flags: nowait postinstall skipifsilent
"@

$issContent | Out-File -FilePath $ISS_FILE -Encoding UTF8

& $ISCC $ISS_FILE

Copy-Item $EXECUTABLE_PATH $DIST_DIR\ | Out-Null
if (Test-Path "$OUTPUT_DIR\$INSTALLER_NAME") {
    Move-Item "$OUTPUT_DIR\$INSTALLER_NAME" $DIST_DIR\
}

Remove-Item $OUTPUT_DIR -Recurse -Force
Remove-Item $ISS_FILE

Write-Host "Created: dist\$INSTALLER_NAME"
