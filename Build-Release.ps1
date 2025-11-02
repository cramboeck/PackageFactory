<#
.SYNOPSIS
    Build portable release package
.DESCRIPTION
    Creates a portable ZIP file for distribution
.PARAMETER Version
    Version number (e.g., "2.1.0"). If not specified, reads from manifest.
.PARAMETER OutputPath
    Output directory for ZIP file (default: ./releases)
.EXAMPLE
    .\Build-Release.ps1
.EXAMPLE
    .\Build-Release.ps1 -Version "2.1.0" -OutputPath "C:\Releases"
.NOTES
    Author: Christoph Ramböck
    Creates: PackageFactory_v{Version}_Portable.zip
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Version,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".\releases"
)

# Get script root
$scriptRoot = $PSScriptRoot

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PackageFactory Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get version from manifest if not specified
if (-not $Version) {
    try {
        $manifestPath = Join-Path $scriptRoot "src\PackageFactory.psd1"
        $manifest = Import-PowerShellDataFile -Path $manifestPath
        $Version = $manifest.ModuleVersion
        Write-Host "[INFO] Version from manifest: $Version" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Could not read version from manifest: $_" -ForegroundColor Red
        exit 1
    }
}

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
    Write-Host "[INFO] Created output directory: $OutputPath" -ForegroundColor Gray
}

# Build directory name
$buildDirName = "PackageFactory_v$Version`_Portable"
$buildPath = Join-Path $env:TEMP $buildDirName
$zipFileName = "$buildDirName.zip"
$zipPath = Join-Path $OutputPath $zipFileName

# Clean old build if exists
if (Test-Path $buildPath) {
    Write-Host "[INFO] Cleaning old build directory..." -ForegroundColor Gray
    Remove-Item -Path $buildPath -Recurse -Force
}

# Create build directory
Write-Host "[INFO] Creating build directory: $buildPath" -ForegroundColor Gray
New-Item -Path $buildPath -ItemType Directory -Force | Out-Null

# Copy files
Write-Host "[INFO] Copying files..." -ForegroundColor Yellow

$filesToCopy = @(
    "src",
    "WebServer",
    "Generator",
    "Config",
    "Modules",
    "Output",
    "Logs",
    "Start-PackageFactory.bat",
    "Start-PackageFactory.ps1",
    "Setup-PortableMode.bat",
    "Setup-PortableMode.ps1",
    "Start-Docker.bat",
    "Start-Docker-Quick.bat",
    "Start-Docker-Quick.ps1",
    "Docker-Rebuild.bat",
    "Docker-Rebuild.ps1",
    "Create-IntuneWin.ps1",
    "docker-compose.yml",
    "Dockerfile",
    "README.md",
    "LICENSE",
    "CHANGELOG.md",
    "QUICKSTART.md",
    "DOCKER.md",
    "DOCKER_QUICKSTART.md",
    "STRUCTURE.md",
    "TROUBLESHOOTING.md",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "CODE_OF_CONDUCT.md"
)

foreach ($file in $filesToCopy) {
    $sourcePath = Join-Path $scriptRoot $file
    if (Test-Path $sourcePath) {
        $destPath = Join-Path $buildPath $file

        if (Test-Path $sourcePath -PathType Container) {
            # Copy directory
            Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
            Write-Host "  ✓ $file (directory)" -ForegroundColor Green
        }
        else {
            # Copy file
            Copy-Item -Path $sourcePath -Destination $destPath -Force
            Write-Host "  ✓ $file" -ForegroundColor Green
        }
    }
    else {
        Write-Host "  ⚠ $file (not found, skipping)" -ForegroundColor Yellow
    }
}

# Create VERSION.txt file
$versionFile = Join-Path $buildPath "VERSION.txt"
@"
PackageFactory Portable Edition
Version: $Version
Build Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Build Host: $env:COMPUTERNAME

Installation:
1. Extract ZIP file
2. Run Start-PackageFactory.bat
3. Browser opens at http://localhost:8080

For offline use:
1. Run Setup-PortableMode.bat once with internet
2. Copy folder to offline location
3. Run Start-PackageFactory.bat

Documentation: See README.md
"@ | Set-Content -Path $versionFile -Encoding UTF8

Write-Host "  ✓ VERSION.txt" -ForegroundColor Green

# Create ZIP file
Write-Host ""
Write-Host "[INFO] Creating ZIP file..." -ForegroundColor Yellow

if (Test-Path $zipPath) {
    Remove-Item -Path $zipPath -Force
    Write-Host "[INFO] Removed old ZIP file" -ForegroundColor Gray
}

try {
    Compress-Archive -Path "$buildPath\*" -DestinationPath $zipPath -CompressionLevel Optimal -Force
    Write-Host "[OK] ZIP file created successfully!" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Failed to create ZIP: $_" -ForegroundColor Red
    exit 1
}

# Get file size
$zipSize = (Get-Item $zipPath).Length
$zipSizeMB = [math]::Round($zipSize / 1MB, 2)

# Clean up temp build directory
Remove-Item -Path $buildPath -Recurse -Force

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Build Completed Successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Package: $zipFileName" -ForegroundColor Cyan
Write-Host "Location: $zipPath" -ForegroundColor Cyan
Write-Host "Size: $zipSizeMB MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Test the ZIP file" -ForegroundColor White
Write-Host "  2. Create GitHub release" -ForegroundColor White
Write-Host "  3. Upload ZIP to release assets" -ForegroundColor White
Write-Host ""
