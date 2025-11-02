<#
.SYNOPSIS
    Gets the PackageFactory root directory
.DESCRIPTION
    Returns the root directory of the PackageFactory installation
#>
function Get-PackageFactoryRoot {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if ($script:PackageFactoryRoot) {
        return $script:PackageFactoryRoot
    }

    # Fallback: try to find root based on module location
    $moduleRoot = Split-Path -Parent $PSScriptRoot
    if (Test-Path (Join-Path $moduleRoot "Generator")) {
        return $moduleRoot
    }

    # If module is in src/, go one level up
    $parentPath = Split-Path -Parent $moduleRoot
    if (Test-Path (Join-Path $parentPath "Generator")) {
        return $parentPath
    }

    throw "Could not determine PackageFactory root directory"
}
