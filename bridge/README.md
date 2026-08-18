# SevenzEA Bridge

SevenzEA Bridge is a read-only telemetry gateway between MT5/SevenzEA and the
SE7EN GOLD IQ website. It does not expose order placement or account-control
routes.

## Data flow

1. SevenzEA posts IQ telemetry to `POST /v1/ea/telemetry`.
2. The bridge reads price, account, positions and closed-deal statistics from
   the locally logged-in MT5 terminal.
3. `GET /v1/snapshot` merges both sources for the website.
4. Every route requires the same long Bearer token.

## Windows quick start

1. Keep MT5 open and logged in on the same PC/VPS.
2. Open PowerShell in this folder.
3. Run `Set-ExecutionPolicy -Scope Process Bypass`.
4. Run `.\scripts\setup_windows.ps1`.
5. Run `.\scripts\start_bridge.bat`.
6. In MT5, allow `http://127.0.0.1:8787` under **Tools → Options → Expert Advisors → Allow WebRequest**.
7. Enable the EA's Bridge inputs and paste the key from `.env` into
   `InpBridgeAccessKey`.
8. Run `.\scripts\check_bridge.ps1`.

For internet access, publish only `http://127.0.0.1:8787` through a managed
HTTPS tunnel. Never open port 8787 directly on the router or firewall.

