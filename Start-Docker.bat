@echo off
REM ============================================
REM Package Factory v2.0 - Docker Launcher
REM Author: Christoph Ramboeck (c@ramboeck.it)
REM ============================================

echo.
echo ========================================
echo    Package Factory v2.0 - Docker
echo    Starting Container...
echo ========================================
echo.

REM Check if Docker is installed
where docker >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Docker not found!
    echo.
    echo Please install Docker Desktop:
    echo https://www.docker.com/products/docker-desktop
    echo.
    pause
    exit /b 1
)

REM Check if Docker is running
docker ps >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Docker is not running!
    echo.
    echo Please start Docker Desktop and try again.
    echo.
    pause
    exit /b 1
)

REM Start with docker-compose
echo Starting Package Factory with Docker Compose...
echo.

docker-compose up -d

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo    Package Factory Started!
    echo ========================================
    echo.
    echo Web-GUI: http://localhost:8080
    echo.
    echo Commands:
    echo   docker-compose logs -f      View logs
    echo   docker-compose down         Stop
    echo   docker-compose restart      Restart
    echo.
    echo Opening browser...
    timeout /t 2 /nobreak >nul
    start http://localhost:8080
) else (
    echo.
    echo ERROR: Failed to start container
    echo.
    echo Try:
    echo   docker-compose build --no-cache
    echo   docker-compose up
    echo.
)

pause
