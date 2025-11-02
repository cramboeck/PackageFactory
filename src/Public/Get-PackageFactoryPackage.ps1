<#
.SYNOPSIS
    Lists created packages
.DESCRIPTION
    Returns information about all packages in the output directory
.PARAMETER OutputPath
    Custom output path (optional, uses config default)
.EXAMPLE
    Get-PackageFactoryPackage
.EXAMPLE
    Get-PackageFactoryPackage | Where-Object { $_.Name -like "*Adobe*" }
.NOTES
    Author: Christoph Ramböck (c@ramboeck.it)
    Version: 2.1.0
#>
function Get-PackageFactoryPackage {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$OutputPath
    )

    if (-not $OutputPath) {
        $config = Get-PackageFactoryConfig
        $OutputPath = $config.OutputPath
    }

    if (-not (Test-Path $OutputPath)) {
        Write-Warning "Output path does not exist: $OutputPath"
        return @()
    }

    $packages = @()
    Get-ChildItem -Path $OutputPath -Directory | ForEach-Object {
        $readmePath = Join-Path $_.FullName "README.md"
        $invokeScriptPath = Join-Path $_.FullName "Invoke-AppDeployToolkit.ps1"

        $packages += [PSCustomObject]@{
            PSTypeName       = 'PackageFactory.PackageInfo'
            Name             = $_.Name
            Path             = $_.FullName
            Created          = $_.CreationTime
            LastModified     = $_.LastWriteTime
            HasReadme        = (Test-Path $readmePath)
            HasDeployScript  = (Test-Path $invokeScriptPath)
            SizeKB           = [math]::Round((Get-ChildItem -Path $_.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1KB, 2)
        }
    }

    return $packages
}
