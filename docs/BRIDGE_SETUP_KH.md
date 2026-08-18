# របៀបភ្ជាប់ SevenzEA Bridge ជាមួយ SE7EN GOLD IQ

Bridge v1 គឺ **Read-only monitoring**។ វាអានតម្លៃ XAUUSD, ស្ថានភាព MT5,
P&L និង IQ Signal ពី EA។ វាមិនមាន API សម្រាប់បញ្ជា BUY/SELL ឬ CLOSE ALL ទេ។

## 1. រៀបចំ Bridge លើ PC/VPS ដែលមាន MT5

1. បើក MT5 និង Login Demo account ជាមុន។
2. ចូល folder `bridge` ហើយបើក PowerShell ជា Administrator។
3. Run:
   `Set-ExecutionPolicy -Scope Process Bypass`
4. Run:
   `.\scripts\setup_windows.ps1`
5. Run Bridge:
   `.\scripts\start_bridge.bat`

Setup script នឹងបង្កើត `.env` និង Bearer Access Key ថ្មីដោយស្វ័យប្រវត្តិ។
កុំ upload ឯកសារ `.env` ទៅ GitHub និងកុំបង្ហាញ key ជាសាធារណៈ។

## 2. អនុញ្ញាត WebRequest ក្នុង MT5

1. MT5 → **Tools → Options → Expert Advisors**។
2. Tick **Allow WebRequest for listed URL**។
3. Add: `http://127.0.0.1:8787`
4. Attach SevenzEA v1.44 ទៅ chart។
5. Set `InpBridgeEnabled=true`។
6. Set `InpBridgeUrl=http://127.0.0.1:8787`។
7. Copy key ពី `bridge/.env` ទៅ `InpBridgeAccessKey`។

## 3. ពិនិត្យ Connection

Run `.\scripts\check_bridge.ps1`។ `eaTelemetry.fresh=true` មានន័យថា EA
កំពុងផ្ញើ IQ Signal បានត្រឹមត្រូវ។

## 4. បង្កើត HTTPS Tunnel

បង្កើត Cloudflare Tunnel ពី hostname ដូចជា `bridge.sevenz-ea.uk` ទៅ
`http://127.0.0.1:8787`។ កុំបើក port 8787 ទៅ Internet ដោយផ្ទាល់។

បន្ទាប់មក Website ត្រូវការតែ៖

- `SEVENZ_BRIDGE_URL=https://bridge.sevenz-ea.uk`
- `SEVENZ_BRIDGE_ACCESS_KEY=<key from bridge/.env>`

