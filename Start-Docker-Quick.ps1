# =====================================================
# PackageFactory v2.0 - Docker Quick Start Script
# Fixes common issues and starts the container
# =====================================================

param(
    [int]$Port = 8080,
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PackageFactory v2.0 - Docker Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "[INFO] Working directory: $ScriptDir" -ForegroundColor Gray
Write-Host ""

# Check Docker
Write-Host "[1/6] Checking Docker..." -ForegroundColor Yellow
try {
    $null = docker --version
    Write-Host "  ✓ Docker found" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Docker not found or not running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Docker Desktop:" -ForegroundColor Yellow
    Write-Host "  https://www.docker.com/products/docker-desktop" -ForegroundColor Cyan
    exit 1
}

# Check if Docker is running
Write-Host "[2/6] Checking Docker daemon..." -ForegroundColor Yellow
try {
    $null = docker ps 2>&1
    Write-Host "  ✓ Docker daemon is running" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Docker daemon not running!" -ForegroundColor Red
    Write-Host "  Please start Docker Desktop" -ForegroundColor Yellow
    exit 1
}

# Check for docker-compose.yml
Write-Host "[3/6] Checking configuration..." -ForegroundColor Yellow
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "  ✗ docker-compose.yml not found!" -ForegroundColor Red
    Write-Host "  Current directory: $ScriptDir" -ForegroundColor Yellow
    exit 1
}
Write-Host "  ✓ docker-compose.yml found" -ForegroundColor Green

# Clean up old containers if requested
if ($Clean) {
    Write-Host "[4/6] Cleaning up old containers..." -ForegroundColor Yellow

    # Find all containers related to packagefactory
    $containers = docker ps -a --filter "name=packagefactory" --format "{{.Names}}"
    if ($containers) {
        foreach ($container in $containers) {
            Write-Host "  → Removing container: $container" -ForegroundColor Gray
            docker rm -f $container 2>&1 | Out-Null
        }
        Write-Host "  ✓ Old containers removed" -ForegroundColor Green
    } else {
        Write-Host "  ✓ No old containers found" -ForegroundColor Green
    }

    # Remove old images
    $images = docker images --filter "reference=*packagefactory*" --format "{{.Repository}}:{{.Tag}}"
    if ($images) {
        foreach ($image in $images) {
            Write-Host "  → Removing image: $image" -ForegroundColor Gray
            docker rmi -f $image 2>&1 | Out-Null
        }
        Write-Host "  ✓ Old images removed" -ForegroundColor Green
    }
} else {
    Write-Host "[4/6] Stopping existing containers..." -ForegroundColor Yellow
    try {
        docker-compose down 2>&1 | Out-Null
        Write-Host "  ✓ Stopped" -ForegroundColor Green
    } catch {
        Write-Host "  ✓ No running containers" -ForegroundColor Green
    }
}

# Check if port is available
Write-Host "[5/6] Checking port $Port..." -ForegroundColor Yellow
$portInUse = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "  ✗ Port $Port is in use!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Process using port $Port:" -ForegroundColor Yellow
    $processId = $portInUse[0].OwningProcess
    Get-Process -Id $processId | Format-Table Id, ProcessName, Path -AutoSize
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  1. Kill the process: taskkill /PID $processId /F" -ForegroundColor Gray
    Write-Host "  2. Use different port: .\Start-Docker-Quick.ps1 -Port 9090" -ForegroundColor Gray
    Write-Host ""

    $response = Read-Host "Try different port 9090? (y/n)"
    if ($response -eq 'y') {
        $Port = 9090
        Write-Host "  → Using port $Port" -ForegroundColor Cyan
    } else {
        exit 1
    }
} else {
    Write-Host "  ✓ Port $Port is available" -ForegroundColor Green
}

# Update docker-compose.yml if needed
if ($Port -ne 8080) {
    Write-Host "  → Updating docker-compose.yml for port $Port..." -ForegroundColor Gray
    $composeContent = Get-Content "docker-compose.yml" -Raw
    $composeContent = $composeContent -replace '- "\d+:8080"', "- `"$Port:8080`""
    $composeContent | Set-Content "docker-compose.yml" -Encoding UTF8
    Write-Host "  ✓ Configuration updated" -ForegroundColor Green
}

# Start container
Write-Host "[6/6] Starting PackageFactory container..." -ForegroundColor Yellow
Write-Host ""

try {
    # Build and start
    if ($Clean) {
        Write-Host "  Building image (this may take a few minutes)..." -ForegroundColor Gray
        docker-compose build --no-cache 2>&1 | Out-Null
    }

    Write-Host "  Starting services..." -ForegroundColor Gray
    docker-compose up -d

    if ($LASTEXITCODE -ne 0) {
        throw "docker-compose failed"
    }

    Write-Host ""
    Write-Host "  ✓ Container started successfully!" -ForegroundColor Green

} catch {
    Write-Host ""
    Write-Host "  ✗ Failed to start container!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error details:" -ForegroundColor Yellow
    docker-compose logs --tail 50
    exit 1
}

# Wait for server to be ready
Write-Host ""
Write-Host "Waiting for server to start..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0

while ($attempt -lt $maxAttempts) {
    try {
        $response = Invoke-WebRequest "http://localhost:$Port" -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ Server is ready!" -ForegroundColor Green
            break
        }
    } catch {
        $attempt++
        Write-Host "  → Attempt $attempt/$maxAttempts..." -ForegroundColor Gray
        Start-Sleep -Seconds 1
    }
}

if ($attempt -ge $maxAttempts) {
    Write-Host "  ✗ Server did not respond in time" -ForegroundColor Red
    Write-Host ""
    Write-Host "Checking logs:" -ForegroundColor Yellow
    docker-compose logs --tail 50
    exit 1
}

# Success!
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  PackageFactory v2.0 Started!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Web-GUI: http://localhost:$Port" -ForegroundColor Cyan
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Yellow
Write-Host "  docker-compose logs -f       View logs" -ForegroundColor Gray
Write-Host "  docker-compose down          Stop container" -ForegroundColor Gray
Write-Host "  docker-compose restart       Restart container" -ForegroundColor Gray
Write-Host ""

# Open browser
Write-Host "Opening browser..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
try {
    Start-Process "http://localhost:$Port"
} catch {
    Write-Host "Could not open browser automatically" -ForegroundColor Yellow
    Write-Host "Please open manually: http://localhost:$Port" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
