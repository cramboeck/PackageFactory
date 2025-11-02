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
    Write-Host "[WARN] Pode module not found in Modules\ folder" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Checking if Pode is already installed globally..." -ForegroundColor Gray

    # Check if Pode is already installed in user or system modules
    $podeInstalled = Get-Module -ListAvailable -Name Pode -ErrorAction SilentlyContinue

    if ($podeInstalled) {
        Write-Host "[OK] Found Pode module installed globally (Version: $($podeInstalled.Version))" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "[INFO] Pode not found. Attempting to download to Modules\ folder..." -ForegroundColor Yellow
        Write-Host ""

        try {
            # Ensure TLS 1.2 is enabled (required for PowerShell Gallery)
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            # Try to install Pode to local Modules folder
            Write-Host "[INFO] Downloading Pode module from PowerShell Gallery..." -ForegroundColor Gray
            $modulesPath = Join-Path $ScriptRoot "Modules"
            $null = New-Item -Path $modulesPath -ItemType Directory -Force

            # Try Save-Module (doesn't require admin or special permissions)
            Save-Module -Name Pode -Path $modulesPath -Force -ErrorAction Stop

            if (Test-Path $podeModulePath) {
                $env:PSModulePath = "$modulesPath;$env:PSModulePath"
                Write-Host "[OK] Pode module downloaded successfully to Modules\ folder" -ForegroundColor Green
                Write-Host ""
            }
        }
        catch {
            Write-Host ""
            Write-Host "[ERROR] Failed to download Pode module automatically" -ForegroundColor Red
            Write-Host ""
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Yellow
            Write-Host "  QUICK FIX - Choose One:" -ForegroundColor Yellow
            Write-Host "========================================" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Option 1: Install Pode globally (EASIEST)" -ForegroundColor Cyan
            Write-Host "  1. Open PowerShell as Administrator" -ForegroundColor White
            Write-Host "  2. Run: Install-Module Pode -Force" -ForegroundColor White
            Write-Host "  3. Close this window and run Start-PackageFactory.bat again" -ForegroundColor White
            Write-Host ""
            Write-Host "Option 2: Run Setup-PortableMode.bat" -ForegroundColor Cyan
            Write-Host "  1. Close this window" -ForegroundColor White
            Write-Host "  2. Right-click Setup-PortableMode.bat → Run as Administrator" -ForegroundColor White
            Write-Host "  3. Then run Start-PackageFactory.bat again" -ForegroundColor White
            Write-Host ""
            Write-Host "Option 3: Use Docker (No PowerShell modules needed)" -ForegroundColor Cyan
            Write-Host "  Run: Start-Docker-Quick.bat" -ForegroundColor White
            Write-Host ""
            Write-Host "Option 4: Manual Download" -ForegroundColor Cyan
            Write-Host "  1. Go to: https://www.powershellgallery.com/packages/Pode" -ForegroundColor White
            Write-Host "  2. Download Pode.nupkg" -ForegroundColor White
            Write-Host "  3. Rename to Pode.zip and extract to: Modules\Pode" -ForegroundColor White
            Write-Host ""
            Write-Host "Common Issues:" -ForegroundColor Cyan
            Write-Host "  - PowerShellGet/PackageManagement too old → Update Windows or install PowerShell 7" -ForegroundColor Gray
            Write-Host "  - Corporate proxy blocking access → Ask IT or use Option 4 (manual download)" -ForegroundColor Gray
            Write-Host "  - No admin rights → Use Option 4 or contact your IT admin" -ForegroundColor Gray
            Write-Host ""
            Read-Host "Press Enter to exit"
            exit 1
        }
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
