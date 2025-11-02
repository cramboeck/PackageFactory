<#
.SYNOPSIS
    Removes a package
.DESCRIPTION
    Deletes a package from the output directory
.PARAMETER Name
    Package name to remove
.PARAMETER Force
    Skip confirmation prompt
.EXAMPLE
    Remove-PackageFactoryPackage -Name "MSP_Adobe_Reader_24.1.0_x64"
.EXAMPLE
    Remove-PackageFactoryPackage -Name "MSP_Adobe_Reader_24.1.0_x64" -Force
.NOTES
    Author: Christoph Ramböck (c@ramboeck.it)
    Version: 2.1.0
#>
function Remove-PackageFactoryPackage {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    process {
        $config = Get-PackageFactoryConfig
        $packagePath = Join-Path $config.OutputPath $Name

        if (-not (Test-Path $packagePath)) {
            Write-Error "Package not found: $Name"
            return
        }

        if ($Force -or $PSCmdlet.ShouldProcess($Name, "Remove package")) {
            try {
                Remove-Item -Path $packagePath -Recurse -Force -ErrorAction Stop
                Write-Host "Package removed: $Name" -ForegroundColor Green
            }
            catch {
                Write-Error "Failed to remove package: $_"
            }
        }
    }
}
