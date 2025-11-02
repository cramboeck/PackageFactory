@echo off
REM ============================================
REM Package Factory v2.0 - Portable Launcher
REM Author: Christoph Ramboeck (c@ramboeck.it)
REM ============================================

echo.
echo ========================================
echo    Package Factory v2.0 Portable
echo    Starting Web Server...
echo ========================================
echo.

REM Check if PowerShell is available
where powershell.exe >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell not found!
    echo Please install PowerShell to use Package Factory.
    pause
    exit /b 1
)

REM Get script directory
set "SCRIPT_DIR=%~dp0"

REM Start PowerShell launcher
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%SCRIPT_DIR%Start-PackageFactory.ps1"

pause
