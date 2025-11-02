<#
.SYNOPSIS
    Downloads and installs PSAppDeployToolkit
.DESCRIPTION
    Downloads PSAppDeployToolkit 4.1.7 from GitHub and extracts it to the package
#>
function Install-PSAppDeployToolkit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    $psadtUrl = "https://github.com/PSAppDeployToolkit/PSAppDeployToolkit/releases/download/4.1.7/PSAppDeployToolkit_v4.1.7.zip"
    $psadtZipPath = Join-Path $env:TEMP "PSAppDeployToolkit_v4.1.7.zip"
    $psadtExtractPath = Join-Path $env:TEMP "PSAppDeployToolkit_Extract"

    try {
        $ProgressPreference = 'SilentlyContinue'
        Write-Verbose "Downloading PSADT from $psadtUrl"
        Invoke-WebRequest -Uri $psadtUrl -OutFile $psadtZipPath -UseBasicParsing
        Write-Verbose "PSADT downloaded successfully"

        if (Test-Path $psadtExtractPath) {
            Remove-Item $psadtExtractPath -Recurse -Force
        }
        Expand-Archive -Path $psadtZipPath -DestinationPath $psadtExtractPath -Force
        Write-Verbose "PSADT extracted successfully"

        $psadtSourceFolder = Get-ChildItem -Path $psadtExtractPath -Directory -Recurse |
            Where-Object { $_.Name -eq "PSAppDeployToolkit" } |
            Select-Object -First 1

        if ($psadtSourceFolder) {
            $psadtDestination = Join-Path $DestinationPath "PSAppDeployToolkit"
            Copy-Item -Path $psadtSourceFolder.FullName -Destination $psadtDestination -Recurse -Force
            Write-Verbose "PSADT copied to package"
        }
        else {
            throw "PSADT folder not found in downloaded archive"
        }

        # Cleanup
        Remove-Item $psadtZipPath -Force -ErrorAction SilentlyContinue
        Remove-Item $psadtExtractPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    catch {
        throw "Failed to download/install PSAppDeployToolkit: $_"
    }
}
