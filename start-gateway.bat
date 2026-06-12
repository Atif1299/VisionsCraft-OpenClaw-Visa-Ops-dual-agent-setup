@echo off
cd /d "%~dp0"
echo Starting OpenClaw Gateway (keep this window open)...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-gateway.ps1"
