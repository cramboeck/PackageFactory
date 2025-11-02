<#
.SYNOPSIS
    PackageFactory PowerShell Module
.DESCRIPTION
    Professional MSP package generator for Microsoft Intune deployments
.NOTES
    Author: Christoph Ramböck (c@ramboeck.it)
    Version: 2.1.0
    License: MIT
#>

# Module variables
$script:ModuleRoot = $PSScriptRoot
$script:PackageFactoryRoot = Split-Path -Parent $PSScriptRoot

# Import private functions
$privateFunctions = @(Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue)
foreach ($import in $privateFunctions) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import private function $($import.FullName): $_"
    }
}

# Import public functions
$publicFunctions = @(Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue)
foreach ($import in $publicFunctions) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import public function $($import.FullName): $_"
    }
}

# Export public functions
Export-ModuleMember -Function $publicFunctions.BaseName

# Module initialization
Write-Verbose "PackageFactory module loaded from: $PSScriptRoot"
