<#
.SYNOPSIS
    Gets the PackageFactory configuration
.DESCRIPTION
    Loads configuration from settings.json or returns defaults
#>
function Get-PackageFactoryConfig {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ConfigPath
    )

    if (-not $ConfigPath) {
        $root = Get-PackageFactoryRoot
        $ConfigPath = Join-Path $root "Config\settings.json"
    }

    try {
        if (Test-Path $ConfigPath) {
            $content = Get-Content $ConfigPath -Raw -ErrorAction Stop
            $config = $content | ConvertFrom-Json -ErrorAction Stop

            # Ensure OutputPath is resolved
            if ($config.OutputPath) {
                if (-not [System.IO.Path]::IsPathRooted($config.OutputPath)) {
                    $root = Get-PackageFactoryRoot
                    $config.OutputPath = Join-Path $root $config.OutputPath
                }
            }
            else {
                $root = Get-PackageFactoryRoot
                $config | Add-Member -NotePropertyName OutputPath -NotePropertyValue (Join-Path $root "Output") -Force
            }

            return $config
        }
        else {
            # Return default config
            $root = Get-PackageFactoryRoot
            return [PSCustomObject]@{
                CompanyPrefix   = "MSP"
                DefaultArch     = "x64"
                DefaultLang     = "EN"
                IncludePSADT    = $true
                AutoOpenBrowser = $true
                OutputPath      = (Join-Path $root "Output")
            }
        }
    }
    catch {
        Write-Warning "Failed to load config from $ConfigPath : $_. Using defaults."
        $root = Get-PackageFactoryRoot
        return [PSCustomObject]@{
            CompanyPrefix   = "MSP"
            DefaultArch     = "x64"
            DefaultLang     = "EN"
            IncludePSADT    = $true
            AutoOpenBrowser = $true
            OutputPath      = (Join-Path $root "Output")
        }
    }
}
