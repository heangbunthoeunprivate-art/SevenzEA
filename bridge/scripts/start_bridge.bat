@echo off
setlocal
cd /d "%~dp0.."
if not exist ".venv\Scripts\python.exe" (
  echo Bridge is not installed. Run setup_windows.ps1 first.
  exit /b 1
)
".venv\Scripts\python.exe" run_bridge.py

