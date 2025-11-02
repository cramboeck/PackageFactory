<#
.SYNOPSIS
    Expands template placeholders
.DESCRIPTION
    Replaces placeholders in template content with actual values
#>
function Expand-PackageFactoryTemplate {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content,

        [Parameter(Mandatory = $true)]
        [hashtable]$Replacements
    )

    $result = $Content
    foreach ($key in $Replacements.Keys) {
        $result = $result -replace [regex]::Escape($key), $Replacements[$key]
    }
    return $result
}
