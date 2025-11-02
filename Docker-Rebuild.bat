@echo off
REM Package Factory v2.0 - Docker Rebuild Script
REM Stops, removes old containers/images, and rebuilds with latest code

cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Docker-Rebuild.ps1"
