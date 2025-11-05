<#
.SYNOPSIS
    Copies PSAppDeployToolkit from local template folder
.DESCRIPTION
    Copies PSAppDeployToolkit 4.1.7 from Generator\PSAppDeployToolkit to the package
    Excludes Invoke-AppDeployToolkit.ps1 to avoid overwriting the generated one
.PARAMETER SourcePath
    Source path where PSADT is stored (Generator\PSAppDeployToolkit)
.PARAMETER DestinationPath
    Destination package path
#>
function Install-PSAppDeployToolkit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    try {
        # Check if source PSADT folder exists
        if (-not (Test-Path $SourcePath)) {
            throw "PSADT source folder not found: $SourcePath. Please download PSADT 4.1.7 and extract to Generator\PSAppDeployToolkit\"
        }

        # Check if PSADT module file exists
        $psadtModule = Join-Path $SourcePath "PSAppDeployToolkit.psd1"
        if (-not (Test-Path $psadtModule)) {
            throw "PSADT module not found: $psadtModule. Please ensure PSAppDeployToolkit is properly extracted."
        }

        Write-Verbose "Copying PSADT from local folder: $SourcePath"

        $psadtDestination = Join-Path $DestinationPath "PSAppDeployToolkit"

        # Copy PSADT folder
        Copy-Item -Path $SourcePath -Destination $psadtDestination -Recurse -Force
        Write-Verbose "PSADT copied to package"

        # Remove Invoke-AppDeployToolkit.ps1 if it exists in PSADT folder
        # (Our generated version is in the package root, not in PSAppDeployToolkit/)
        $invokeInPSADT = Join-Path $psadtDestination "Invoke-AppDeployToolkit.ps1"
        if (Test-Path $invokeInPSADT) {
            Remove-Item $invokeInPSADT -Force
            Write-Verbose "Removed original Invoke-AppDeployToolkit.ps1 from PSADT folder (using generated version)"
        }

        # Copy Invoke-AppDeployToolkit.exe from parent template folder
        # This EXE is needed for Intune deployments and system context execution
        $parentTemplatePath = Split-Path $SourcePath -Parent
        $invokeExeSource = Join-Path $parentTemplatePath "Invoke-AppDeployToolkit.exe"
        if (Test-Path $invokeExeSource) {
            $invokeExeDest = Join-Path $DestinationPath "Invoke-AppDeployToolkit.exe"
            Copy-Item -Path $invokeExeSource -Destination $invokeExeDest -Force
            Write-Verbose "Copied Invoke-AppDeployToolkit.exe to package root"
        } else {
            Write-Warning "Invoke-AppDeployToolkit.exe not found at: $invokeExeSource"
        }

        Write-Verbose "PSADT installation completed successfully"
    }
    catch {
        throw "Failed to copy PSAppDeployToolkit: $_"
    }
}
