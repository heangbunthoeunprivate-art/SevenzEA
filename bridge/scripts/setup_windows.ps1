$ErrorActionPreference = "Stop"
$BridgeRoot = Split-Path -Parent $PSScriptRoot
$Venv = Join-Path $BridgeRoot ".venv"
$EnvFile = Join-Path $BridgeRoot ".env"

if (-not (Test-Path $Venv)) {
    py -3 -m venv $Venv
}

& "$Venv\Scripts\python.exe" -m pip install --upgrade pip
& "$Venv\Scripts\python.exe" -m pip install -r (Join-Path $BridgeRoot "requirements.txt")

if (-not (Test-Path $EnvFile)) {
    $AccessKey = & "$Venv\Scripts\python.exe" -c "import secrets; print(secrets.token_urlsafe(48))"
    @"
SEVENZ_BRIDGE_ACCESS_KEY=$AccessKey
SEVENZ_BRIDGE_HOST=127.0.0.1
SEVENZ_BRIDGE_PORT=8787
SEVENZ_BRIDGE_ALLOWED_ORIGINS=
SEVENZ_MT5_TERMINAL_PATH=
SEVENZ_MT5_LOGIN=
SEVENZ_MT5_SERVER=
SEVENZ_TELEMETRY_MAX_AGE_SECONDS=20
"@ | Set-Content -Path $EnvFile -Encoding UTF8
    Write-Host "Created .env with a new access key." -ForegroundColor Green
} else {
    Write-Host ".env already exists; the access key was preserved." -ForegroundColor Yellow
}

Write-Host "SevenzEA Bridge setup complete." -ForegroundColor Green
Write-Host "Next: run scripts\start_bridge.bat" -ForegroundColor Cyan

