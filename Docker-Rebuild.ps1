<#
.SYNOPSIS
    Docker Rebuild Script for Package Factory v2.0
.DESCRIPTION
    Stops, removes old containers/images, and rebuilds with latest code
.NOTES
    Author: Christoph Ramboeck (c@ramboeck.it)
    Version: 2.0.1
#>

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Package Factory v2.0" -ForegroundColor Cyan
Write-Host "  Docker Rebuild Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed
try {
    $dockerVersion = docker --version 2>$null
    if (-not $dockerVersion) {
        Write-Host "[ERROR] Docker not found!" -ForegroundColor Red
        Write-Host "Please install Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Host "[OK] Docker is installed: $dockerVersion" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Docker not found!" -ForegroundColor Red
    Write-Host "Please install Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "This will:" -ForegroundColor Yellow
Write-Host "  1. Stop all PackageFactory containers" -ForegroundColor Gray
Write-Host "  2. Remove old containers" -ForegroundColor Gray
Write-Host "  3. Remove old images" -ForegroundColor Gray
Write-Host "  4. Rebuild with latest code" -ForegroundColor Gray
Write-Host "  5. Start new container" -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "Continue? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host ""
    Write-Host "[INFO] Cancelled by user" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host ""

# Step 1: Stop all containers
Write-Host "[1/5] Stopping containers..." -ForegroundColor Cyan
try {
    Push-Location $ScriptRoot
    docker-compose down 2>$null
    Write-Host "      Containers stopped" -ForegroundColor Green
}
catch {
    Write-Host "      No containers to stop" -ForegroundColor Gray
}
finally {
    Pop-Location
}

# Step 2: Remove old PackageFactory containers
Write-Host "[2/5] Removing old containers..." -ForegroundColor Cyan
try {
    $containers = docker ps -a --filter "name=packagefactory" --format "{{.ID}}" 2>$null
    if ($containers) {
        foreach ($container in $containers) {
            docker rm $container -f 2>$null | Out-Null
        }
        Write-Host "      Removed $($containers.Count) container(s)" -ForegroundColor Green
    } else {
        Write-Host "      No old containers found" -ForegroundColor Gray
    }
}
catch {
    Write-Host "      No containers to remove" -ForegroundColor Gray
}

# Step 3: Remove old PackageFactory images
Write-Host "[3/5] Removing old images..." -ForegroundColor Cyan
try {
    $images = docker images --filter "reference=*packagefactory*" --format "{{.ID}}" 2>$null
    if ($images) {
        foreach ($image in $images) {
            docker rmi $image -f 2>$null | Out-Null
        }
        Write-Host "      Removed $($images.Count) image(s)" -ForegroundColor Green
    } else {
        Write-Host "      No old images found" -ForegroundColor Gray
    }
}
catch {
    Write-Host "      No images to remove" -ForegroundColor Gray
}

# Step 4 & 5: Rebuild and start
Write-Host "[4/5] Building new image with --no-cache (this may take 2-3 minutes)..." -ForegroundColor Cyan
Write-Host "      This ensures we get the latest code!" -ForegroundColor Gray
Write-Host "[5/5] Starting new container..." -ForegroundColor Cyan
Write-Host ""

try {
    Push-Location $ScriptRoot
    docker-compose build --no-cache
    docker-compose up -d

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  SUCCESS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Package Factory v2.0.1 is now running!" -ForegroundColor White
    Write-Host ""
    Write-Host "Access at: http://localhost:8080" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To view logs:" -ForegroundColor White
    Write-Host "  docker-compose logs -f" -ForegroundColor Gray
    Write-Host ""
    Write-Host "To stop:" -ForegroundColor White
    Write-Host "  docker-compose down" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "[ERROR] Failed to rebuild: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}
finally {
    Pop-Location
}

# Try to open browser
Write-Host "Opening browser..." -ForegroundColor Gray
Start-Sleep -Seconds 2
try {
    Start-Process "http://localhost:8080"
}
catch {
    Write-Host "Please open browser manually: http://localhost:8080" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit"
