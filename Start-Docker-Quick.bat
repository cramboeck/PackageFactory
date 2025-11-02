@echo off
REM =====================================================
REM PackageFactory v2.0 - Docker Quick Start (Batch)
REM =====================================================

echo.
echo ========================================
echo   PackageFactory v2.0 - Docker Setup
echo ========================================
echo.

REM Change to script directory
cd /d "%~dp0"

echo [1/5] Checking Docker...
docker --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   X Docker not found!
    echo.
    echo Please install Docker Desktop:
    echo   https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo   OK Docker found

echo [2/5] Checking Docker daemon...
docker ps >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   X Docker daemon not running!
    echo   Please start Docker Desktop
    pause
    exit /b 1
)
echo   OK Docker daemon running

echo [3/5] Stopping old containers...
docker-compose down >nul 2>&1
echo   OK Stopped

echo [4/5] Starting PackageFactory...
docker-compose up -d
if %ERRORLEVEL% NEQ 0 (
    echo   X Failed to start container!
    echo.
    echo Showing logs:
    docker-compose logs --tail 50
    pause
    exit /b 1
)
echo   OK Container started

echo [5/5] Waiting for server...
timeout /t 5 /nobreak >nul

REM Test if server responds
curl -s http://localhost:8080 >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   Waiting a bit longer...
    timeout /t 5 /nobreak >nul
)

echo.
echo ========================================
echo   PackageFactory v2.0 Started!
echo ========================================
echo.
echo   Web-GUI: http://localhost:8080
echo.
echo Commands:
echo   docker-compose logs -f      View logs
echo   docker-compose down         Stop
echo   docker-compose restart      Restart
echo.
echo Opening browser...
timeout /t 2 /nobreak >nul
start http://localhost:8080

echo.
echo Press any key to exit...
pause >nul
