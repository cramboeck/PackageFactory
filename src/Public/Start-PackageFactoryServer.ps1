<#
.SYNOPSIS
    Starts the PackageFactory web server
.DESCRIPTION
    Launches a Pode-based web server with REST API and web UI for package creation
.PARAMETER Port
    Port number for the web server (default: 8080)
.PARAMETER AutoOpenBrowser
    Automatically open browser after server starts
.EXAMPLE
    Start-PackageFactoryServer
.EXAMPLE
    Start-PackageFactoryServer -Port 9090
.NOTES
    Author: Christoph Ramböck (c@ramboeck.it)
    Version: 2.1.0
    Requires: Pode module
#>
function Start-PackageFactoryServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(1024, 65535)]
        [int]$Port = 8080,

        [Parameter(Mandatory = $false)]
        [switch]$AutoOpenBrowser
    )

    begin {
        # Check for Pode module
        if (-not (Get-Module -ListAvailable -Name Pode)) {
            throw "Pode module is required. Install it with: Install-Module Pode -Scope CurrentUser"
        }

        Import-Module Pode -ErrorAction Stop

        $rootPath = Get-PackageFactoryRoot
        $serverScript = Join-Path $rootPath "WebServer\Server.ps1"

        if (-not (Test-Path $serverScript)) {
            throw "Server script not found: $serverScript"
        }
    }

    process {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  Package Factory v2.1" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Starting web server on port $Port..." -ForegroundColor Yellow
        Write-Host ""

        # Launch server
        $params = @{
            Port     = $Port
            RootPath = $rootPath
        }

        & $serverScript @params
    }
}
