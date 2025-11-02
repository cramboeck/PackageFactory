@{
    # Script module or binary module file associated with this manifest
    RootModule        = 'PackageFactory.psm1'

    # Version number of this module
    ModuleVersion     = '2.2.0'

    # ID used to uniquely identify this module
    GUID              = 'a8f3c4d2-9e1b-4a7f-8c5d-3b2e9f6a1c4d'

    # Author of this module
    Author            = 'Christoph Ramböck'

    # Company or vendor of this module
    CompanyName       = 'Ramböck IT'

    # Copyright statement for this module
    Copyright         = '(c) 2025 Christoph Ramböck. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'Professional MSP package generator for Microsoft Intune deployments. Create deployment packages with PSAppDeployToolkit integration, web-based GUI, and REST API.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules   = @()

    # Functions to export from this module
    FunctionsToExport = @(
        'New-AutopilotPackage',
        'Start-PackageFactoryServer',
        'Get-PackageFactoryPackage',
        'Remove-PackageFactoryPackage'
    )

    # Cmdlets to export from this module
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport   = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData       = @{
        PSData = @{
            # Tags applied to this module to enable discovery and categorization
            Tags         = @(
                'MSP',
                'Intune',
                'PSADT',
                'PSAppDeployToolkit',
                'Deployment',
                'Packaging',
                'Autopilot',
                'Windows',
                'DevOps'
            )

            # A URL to the license for this module
            LicenseUri   = 'https://github.com/cramboeck/PackageFactory/blob/main/LICENSE'

            # A URL to the main website for this project
            ProjectUri   = 'https://github.com/cramboeck/PackageFactory'

            # A URL to an icon representing this module
            IconUri      = ''

            # Release notes of this module
            ReleaseNotes = @'
# Release Notes - v2.1.0

## New Features
- Modularized PowerShell structure with proper manifest
- Separate public and private functions
- Improved error handling and logging
- SupportsShouldProcess for destructive operations
- Professional module structure for PowerShell Gallery publication

## Improvements
- Better code organization
- Enhanced documentation
- Type definitions for return objects
- Verbose output support

## Breaking Changes
- None (backward compatible with v2.0.x)

## Bug Fixes
- Improved path handling
- Better error messages
'@
        }
    }

    # HelpInfo URI of this module
    HelpInfoURI       = 'https://github.com/cramboeck/PackageFactory/wiki'
}
