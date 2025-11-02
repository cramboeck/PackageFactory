<#
.SYNOPSIS
    Download Pode module for portable mode
.DESCRIPTION
    Downloads Pode module to the Modules folder for truly portable operation
.NOTES
    Author: Christoph Ramboeck (c@ramboeck.it)
    Version: 2.0.1
#>

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulesPath = Join-Path $ScriptRoot "Modules"
$podeModulePath = Join-Path $modulesPath "Pode"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Package Factory v2.0" -ForegroundColor Cyan
Write-Host "  Portable Mode Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Pode already exists
if (Test-Path $podeModulePath) {
    Write-Host "[INFO] Pode module already installed at:" -ForegroundColor Yellow
    Write-Host "       $podeModulePath" -ForegroundColor Gray
    Write-Host ""
    $overwrite = Read-Host "Do you want to re-download? (Y/N)"
    if ($overwrite -ne 'Y' -and $overwrite -ne 'y') {
        Write-Host ""
        Write-Host "[INFO] Setup cancelled" -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 0
    }
    Remove-Item $podeModulePath -Recurse -Force
}

try {
    Write-Host "[INFO] Setting up portable mode..." -ForegroundColor Yellow
    Write-Host ""

    # Ensure TLS 1.2 is enabled
    Write-Host "[1/4] Enabling TLS 1.2..." -ForegroundColor Gray
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Trust PowerShell Gallery
    Write-Host "[2/4] Configuring PowerShell Gallery..." -ForegroundColor Gray
    $psRepository = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
    if ($psRepository -and $psRepository.InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
    }

    # Create Modules directory
    Write-Host "[3/4] Creating Modules directory..." -ForegroundColor Gray
    $null = New-Item -Path $modulesPath -ItemType Directory -Force

    # Download Pode module
    Write-Host "[4/4] Downloading Pode module (this may take a minute)..." -ForegroundColor Gray
    Save-Module -Name Pode -Path $modulesPath -Force -ErrorAction Stop

    Write-Host ""
    Write-Host "[SUCCESS] Portable mode setup completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Pode module installed to:" -ForegroundColor White
    Write-Host "$podeModulePath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You can now run Package Factory without internet connection:" -ForegroundColor White
    Write-Host "  Start-PackageFactory.bat" -ForegroundColor Cyan
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "[ERROR] Failed to download Pode module" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  Troubleshooting" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Cyan
    Write-Host "  1. No internet connection" -ForegroundColor Gray
    Write-Host "  2. Corporate proxy blocking PowerShell Gallery" -ForegroundColor Gray
    Write-Host "  3. PowerShell Gallery temporarily unavailable" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Alternative: Use Docker mode (no module installation needed)" -ForegroundColor Cyan
    Write-Host "  Run: Start-Docker-Quick.bat" -ForegroundColor White
    Write-Host ""
}

Read-Host "Press Enter to exit"
