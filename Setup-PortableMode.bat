@echo off
REM Package Factory v2.0 - Portable Mode Setup
REM This script downloads the Pode module for offline use

cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup-PortableMode.ps1"
