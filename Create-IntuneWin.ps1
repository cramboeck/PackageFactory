<#
.SYNOPSIS
    IntuneWin Package Creator Helper
.DESCRIPTION
    Helper script to create .intunewin packages from generated packages
    Automatically downloads IntuneWinAppUtil if not present
.PARAMETER PackagePath
    Path to the package folder (default: prompts user to select)
.PARAMETER OutputPath
    Where to save the .intunewin file (default: .\IntuneWin)
.EXAMPLE
    .\Create-IntuneWin.ps1
.EXAMPLE
    .\Create-IntuneWin.ps1 -PackagePath ".\Output\Adobe_ReaderDC_24.1.0_x64"
.NOTES
    Author: Christoph Ramboeck (c@ramboeck.it)
    Version: 2.0.0
    Created: 2025-10-29
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$PackagePath,

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\IntuneWin"
)

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ToolsPath = Join-Path $ScriptRoot "Tools"
$IntuneWinAppUtilPath = Join-Path $ToolsPath "IntuneWinAppUtil.exe"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  IntuneWin Package Creator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Ensure Tools directory exists
if (-not (Test-Path $ToolsPath)) {
    New-Item -Path $ToolsPath -ItemType Directory -Force | Out-Null
}

# Check for IntuneWinAppUtil.exe
if (-not (Test-Path $IntuneWinAppUtilPath)) {
    Write-Host "[INFO] IntuneWinAppUtil.exe not found" -ForegroundColor Yellow
    Write-Host "[INFO] Attempting to download from GitHub..." -ForegroundColor Yellow

    $downloadUrl = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/raw/master/IntuneWinAppUtil.exe"

    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $downloadUrl -OutFile $IntuneWinAppUtilPath -UseBasicParsing
        Write-Host "[OK] IntuneWinAppUtil.exe downloaded successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Failed to download IntuneWinAppUtil.exe" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please download manually from:" -ForegroundColor Yellow
        Write-Host "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "And place it in: $ToolsPath" -ForegroundColor Yellow
        exit 1
    }
}

# If no package path specified, list available packages
if (-not $PackagePath) {
    $outputDir = Join-Path $ScriptRoot "Output"

    if (-not (Test-Path $outputDir)) {
        Write-Host "[ERROR] No packages found in Output directory" -ForegroundColor Red
        exit 1
    }

    $packages = Get-ChildItem -Path $outputDir -Directory

    if ($packages.Count -eq 0) {
        Write-Host "[ERROR] No packages found in Output directory" -ForegroundColor Red
        exit 1
    }

    Write-Host "Available packages:" -ForegroundColor Yellow
    Write-Host ""

    for ($i = 0; $i -lt $packages.Count; $i++) {
        Write-Host "  [$($i + 1)] $($packages[$i].Name)" -ForegroundColor White
    }

    Write-Host ""
    $selection = Read-Host "Select package number (1-$($packages.Count))"

    if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $packages.Count) {
        $PackagePath = $packages[[int]$selection - 1].FullName
    }
    else {
        Write-Host "[ERROR] Invalid selection" -ForegroundColor Red
        exit 1
    }
}

# Validate package path
if (-not (Test-Path $PackagePath)) {
    Write-Host "[ERROR] Package path not found: $PackagePath" -ForegroundColor Red
    exit 1
}

# Find Invoke-AppDeployToolkit.ps1
$deployScript = Join-Path $PackagePath "Invoke-AppDeployToolkit.ps1"

if (-not (Test-Path $deployScript)) {
    Write-Host "[ERROR] Invoke-AppDeployToolkit.ps1 not found in package" -ForegroundColor Red
    exit 1
}

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
}

# Get absolute paths
$PackagePath = Resolve-Path $PackagePath
$OutputPath = Resolve-Path $OutputPath

Write-Host ""
Write-Host "Package: $PackagePath" -ForegroundColor Green
Write-Host "Output:  $OutputPath" -ForegroundColor Green
Write-Host ""
Write-Host "Creating .intunewin package..." -ForegroundColor Yellow
Write-Host ""

# Run IntuneWinAppUtil
try {
    & $IntuneWinAppUtilPath `
        -c "$PackagePath" `
        -s "Invoke-AppDeployToolkit.ps1" `
        -o "$OutputPath" `
        -q

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "  IntuneWin Package Created!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Location: $OutputPath" -ForegroundColor White
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "  1. Open Microsoft Endpoint Manager admin center" -ForegroundColor Gray
        Write-Host "  2. Navigate to Apps > All apps > Add" -ForegroundColor Gray
        Write-Host "  3. Select 'Windows app (Win32)'" -ForegroundColor Gray
        Write-Host "  4. Upload the .intunewin file" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Install command:" -ForegroundColor Yellow
        Write-Host "  powershell.exe -ExecutionPolicy Bypass -File `"Invoke-AppDeployToolkit.ps1`" -DeploymentType `"Install`" -DeployMode `"Silent`"" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Uninstall command:" -ForegroundColor Yellow
        Write-Host "  powershell.exe -ExecutionPolicy Bypass -File `"Invoke-AppDeployToolkit.ps1`" -DeploymentType `"Uninstall`" -DeployMode `"Silent`"" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Detection method:" -ForegroundColor Yellow
        Write-Host "  Use custom script: Detect-*.ps1 (found in package folder)" -ForegroundColor Gray
        Write-Host ""
    }
    else {
        Write-Host ""
        Write-Host "[ERROR] IntuneWinAppUtil failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host ""
    Write-Host "[ERROR] Failed to create IntuneWin package: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
