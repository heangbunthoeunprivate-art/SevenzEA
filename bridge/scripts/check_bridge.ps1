$ErrorActionPreference = "Stop"
$BridgeRoot = Split-Path -Parent $PSScriptRoot
$EnvFile = Join-Path $BridgeRoot ".env"
if (-not (Test-Path $EnvFile)) { throw "Missing bridge/.env" }

$AccessKeyLine = Get-Content $EnvFile | Where-Object { $_ -match '^SEVENZ_BRIDGE_ACCESS_KEY=' } | Select-Object -First 1
if (-not $AccessKeyLine) { throw "Missing SEVENZ_BRIDGE_ACCESS_KEY" }
$AccessKey = $AccessKeyLine.Substring($AccessKeyLine.IndexOf('=') + 1)
$Headers = @{ Authorization = "Bearer $AccessKey" }

Invoke-RestMethod -Uri "http://127.0.0.1:8787/v1/health" -Headers $Headers | ConvertTo-Json -Depth 8

