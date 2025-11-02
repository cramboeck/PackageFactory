<#
.SYNOPSIS
    Package Factory v2.0 - Portable Web Server Launcher
.DESCRIPTION
    Starts the embedded Pode web server and opens the browser
.NOTES
    Author: Christoph Ramboeck (c@ramboeck.it)
    Version: 2.0.0
    Created: 2025-10-29
#>

param(
    [Parameter(Mandatory=$false)]
    [int]$Port = 8080
)

# Script directory
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Package Factory v2.0 Portable" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check PowerShell Version
$psVersion = $PSVersionTable.PSVersion
Write-Host "[INFO] PowerShell Version: $($psVersion.Major).$($psVersion.Minor)" -ForegroundColor Gray

if ($psVersion.Major -lt 5 -or ($psVersion.Major -eq 5 -and $psVersion.Minor -lt 1)) {
    Write-Host ""
    Write-Host "[ERROR] PowerShell 5.1 or higher required!" -ForegroundColor Red
    Write-Host "Your version: $($psVersion.Major).$($psVersion.Minor)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Solutions:" -ForegroundColor Yellow
    Write-Host "  1. Install PowerShell 7+ (recommended)" -ForegroundColor White
    Write-Host "     Download: https://aka.ms/powershell" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  2. Update Windows PowerShell to 5.1" -ForegroundColor White
    Write-Host "     (Usually included in Windows 10/11)" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[OK] PowerShell version compatible" -ForegroundColor Green
Write-Host ""

# Check for Pode module (try to install if not embedded yet)
$podeModulePath = Join-Path $ScriptRoot "Modules\Pode"

if (Test-Path $podeModulePath) {
    Write-Host "[OK] Using embedded Pode module" -ForegroundColor Green
    $env:PSModulePath = "$podeModulePath;$env:PSModulePath"
} else {
    Write-Host "[INFO] Pode module not found, attempting to download..." -ForegroundColor Yellow
    Write-Host ""

    try {
        # Ensure TLS 1.2 is enabled (required for PowerShell Gallery)
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        # Trust PowerShell Gallery if needed
        $psRepository = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
        if ($psRepository -and $psRepository.InstallationPolicy -ne 'Trusted') {
            Write-Host "[INFO] Setting PSGallery as trusted repository..." -ForegroundColor Gray
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
        }

        # Try to install Pode to local Modules folder
        Write-Host "[INFO] Downloading Pode module from PowerShell Gallery..." -ForegroundColor Gray
        $modulesPath = Join-Path $ScriptRoot "Modules"
        $null = New-Item -Path $modulesPath -ItemType Directory -Force

        Save-Module -Name Pode -Path $modulesPath -Force -ErrorAction Stop

        $env:PSModulePath = "$podeModulePath;$env:PSModulePath"
        Write-Host "[OK] Pode module downloaded successfully" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host ""
        Write-Host "[ERROR] Failed to download Pode module" -ForegroundColor Red
        Write-Host ""
        Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host "  Manual Installation Options" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Option 1: Install via PowerShell (Recommended)" -ForegroundColor Cyan
        Write-Host "  Run the following command as Administrator:" -ForegroundColor Gray
        Write-Host "  Install-Module Pode -Scope CurrentUser -Force" -ForegroundColor White
        Write-Host ""
        Write-Host "Option 2: Install to portable folder" -ForegroundColor Cyan
        Write-Host "  Run the following commands:" -ForegroundColor Gray
        Write-Host "  Install-Module Pode -Scope CurrentUser" -ForegroundColor White
        Write-Host "  Copy-Item `"$env:USERPROFILE\Documents\PowerShell\Modules\Pode`" -Destination `"$modulesPath`" -Recurse" -ForegroundColor White
        Write-Host ""
        Write-Host "Option 3: Use Docker (No installation needed)" -ForegroundColor Cyan
        Write-Host "  Run: Start-Docker-Quick.bat" -ForegroundColor White
        Write-Host ""
        Write-Host "Troubleshooting:" -ForegroundColor Cyan
        Write-Host "  - Ensure internet connection is active" -ForegroundColor Gray
        Write-Host "  - Check if corporate proxy is blocking PowerShell Gallery" -ForegroundColor Gray
        Write-Host "  - Try running PowerShell as Administrator" -ForegroundColor Gray
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Import Pode
try {
    Import-Module Pode -ErrorAction Stop
    Write-Host "[OK] Pode module loaded" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Failed to import Pode module: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Starting web server on port $Port..." -ForegroundColor Yellow
Write-Host ""

# Start server in background
$serverScript = Join-Path $ScriptRoot "WebServer\Server.ps1"

if (-not (Test-Path $serverScript)) {
    Write-Host "[ERROR] Server.ps1 not found at: $serverScript" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Launch server (will block until stopped)
& $serverScript -Port $Port -RootPath $ScriptRoot

Write-Host ""
Write-Host "Server stopped." -ForegroundColor Yellow
