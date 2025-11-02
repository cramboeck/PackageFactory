<#
.SYNOPSIS
    Creates a new Autopilot deployment package for Microsoft Intune
.DESCRIPTION
    Generates a complete deployment package including:
    - PSADT deployment scripts
    - Detection scripts
    - Package structure
    - Optional PSAppDeployToolkit download
.PARAMETER AppName
    Application name (e.g., "Notepad++")
.PARAMETER AppVendor
    Application vendor (e.g., "Don Ho")
.PARAMETER AppVersion
    Application version (e.g., "8.8.7")
.PARAMETER AppArch
    Architecture: x64, x86, ARM64
.PARAMETER AppLang
    Language code (e.g., EN, DE, FR)
.PARAMETER CompanyPrefix
    Company/MSP prefix for multi-tenant environments
.PARAMETER InstallerType
    Installer type: msi or exe
.PARAMETER MsiFilename
    MSI installer filename
.PARAMETER MsiSilentParams
    MSI silent installation parameters
.PARAMETER ExeFilename
    EXE installer filename
.PARAMETER ExeSilentParams
    EXE silent installation parameters
.PARAMETER ProcessesToClose
    Comma-separated list of processes to close before installation
.PARAMETER IncludePSADT
    Auto-download PSAppDeployToolkit 4.1.5
.PARAMETER OutputPath
    Output directory for generated packages
.EXAMPLE
    New-AutopilotPackage -AppName "7-Zip" -AppVendor "Igor Pavlov" -AppVersion "23.01" -MsiFilename "7z2301-x64.msi"
.EXAMPLE
    New-AutopilotPackage -AppName "Notepad++" -AppVendor "Don Ho" -AppVersion "8.8.7" -CompanyPrefix "ACME" -IncludePSADT
.NOTES
    Author: Christoph Ramböck (c@ramboeck.it)
    Version: 2.1.0
#>
function New-AutopilotPackage {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$AppName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$AppVendor,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$AppVersion,

        [Parameter(Mandatory = $false)]
        [ValidateSet('x64', 'x86', 'ARM64')]
        [string]$AppArch = 'x64',

        [Parameter(Mandatory = $false)]
        [string]$AppLang = 'EN',

        [Parameter(Mandatory = $false)]
        [string]$CompanyPrefix = 'MSP',

        [Parameter(Mandatory = $false)]
        [ValidateSet('msi', 'exe')]
        [string]$InstallerType = 'msi',

        [Parameter(Mandatory = $false)]
        [string]$MsiFilename = '',

        [Parameter(Mandatory = $false)]
        [string]$MsiSilentParams = '/qn /norestart',

        [Parameter(Mandatory = $false)]
        [string]$ExeFilename = '',

        [Parameter(Mandatory = $false)]
        [string]$ExeSilentParams = '',

        [Parameter(Mandatory = $false)]
        [string]$ProcessesToClose = '',

        [Parameter(Mandatory = $false)]
        [switch]$IncludePSADT,

        [Parameter(Mandatory = $false)]
        [string]$OutputPath
    )

    begin {
        Write-Verbose "Starting package creation: $AppVendor $AppName $AppVersion ($AppArch)"

        # Determine paths
        if (-not $OutputPath) {
            $config = Get-PackageFactoryConfig
            $OutputPath = $config.OutputPath
        }

        $templatePath = Join-Path (Get-PackageFactoryRoot) "Generator\Templates\Autopilot-PSADT-4x"

        if (-not (Test-Path $templatePath)) {
            throw "Template not found: $templatePath"
        }
    }

    process {
        try {
            # Generate package name
            $packageName = if ($CompanyPrefix) {
                "$CompanyPrefix`_$AppVendor`_$($AppName.Replace(' ', ''))`_$AppVersion`_$AppArch"
            }
            else {
                "$AppVendor`_$($AppName.Replace(' ', ''))`_$AppVersion`_$AppArch"
            }

            Write-Verbose "Package name: $packageName"

            $packagePath = Join-Path $OutputPath $packageName

            # Check if package exists
            if (Test-Path $packagePath) {
                throw "Package already exists: $packageName. Please delete it first or choose a different version."
            }

            if ($PSCmdlet.ShouldProcess($packagePath, "Create package directory")) {
                # Create package structure
                Write-Verbose "Creating package directory: $packagePath"
                $null = New-Item -Path $packagePath -ItemType Directory -Force
                $filesPath = Join-Path $packagePath "Files"
                $null = New-Item -Path $filesPath -ItemType Directory -Force
                $configPath = Join-Path $filesPath "Config"
                $null = New-Item -Path $configPath -ItemType Directory -Force
            }

            # Prepare replacement values
            $date = Get-Date -Format "yyyy-MM-dd"
            $appRevision = "01"

            $processesFormatted = if ($ProcessesToClose) {
                ($ProcessesToClose.Split(',') | ForEach-Object { "'$($_.Trim())'" }) -join ', '
            }
            else {
                ""
            }

            # Determine installer commands - PSADT 4.1.7 correct syntax
            if ($InstallerType -eq 'msi') {
                $installerFile = if ($MsiFilename) { $MsiFilename } else { "setup.msi" }
                $silentParams = $MsiSilentParams

                # Install command with proper variable usage
                $installCmd = @"
        # MSI Installation
        `$installerPath = Join-Path -Path `$adtSession.DirFiles -ChildPath "$installerFile"
        `$arguments = "$silentParams"

        Start-ADTMsiProcess -Action Install -FilePath `$installerPath -Parameters `$arguments
"@

                # Uninstall command
                $uninstallCmd = @"
        # MSI Uninstallation
        `$installerPath = Join-Path -Path `$adtSession.DirFiles -ChildPath "$installerFile"
        `$arguments = "/qn /norestart"

        Start-ADTMsiProcess -Action Uninstall -FilePath `$installerPath -Parameters `$arguments
"@
            }
            else {
                $installerFile = if ($ExeFilename) { $ExeFilename } else { "setup.exe" }
                $silentParams = $ExeSilentParams

                # Install command with proper variable usage
                $installCmd = @"
        # EXE Installation
        `$installerPath = Join-Path -Path `$adtSession.DirFiles -ChildPath "$installerFile"
        `$arguments = "$silentParams"

        Start-ADTProcess -FilePath `$installerPath -ArgumentList `$arguments -Wait
"@

                # Uninstall command - customize per application
                $uninstallCmd = @"
        # EXE Uninstallation - Customize as needed
        # Option 1: If uninstaller exists in Files folder
        `$uninstallerPath = Join-Path -Path `$adtSession.DirFiles -ChildPath "uninstall.exe"
        if (Test-Path -Path `$uninstallerPath) {
            `$arguments = "$silentParams"
            Start-ADTProcess -FilePath `$uninstallerPath -ArgumentList `$arguments -Wait
        }

        # Option 2: Registry-based uninstall string
        # `$uninstallString = Get-ADTUninstallKey -ApplicationName "$($AppName)" | Select-Object -ExpandProperty UninstallString
        # if (`$uninstallString) {
        #     Start-ADTProcess -FilePath `$uninstallString -ArgumentList "$silentParams" -Wait
        # }
"@
            }

            $replacements = @{
                '{{APP_NAME}}'          = $AppName
                '{{APP_VENDOR}}'        = $AppVendor
                '{{APP_VERSION}}'       = $AppVersion
                '{{APP_ARCH}}'          = $AppArch
                '{{APP_LANG}}'          = $AppLang
                '{{APP_REVISION}}'      = $appRevision
                '{{COMPANY_PREFIX}}'    = $CompanyPrefix
                '{{DATE}}'              = $date
                '{{INSTALLER_TYPE}}'    = $InstallerType.ToUpper()
                '{{INSTALLER_FILE}}'    = $installerFile
                '{{SILENT_PARAMS}}'     = $silentParams
                '{{MSI_FILENAME}}'      = $MsiFilename
                '{{EXE_FILENAME}}'      = $ExeFilename
                '{{PROCESSES_TO_CLOSE}}' = $processesFormatted
                '{{INSTALL_COMMAND}}'   = $installCmd
                '{{UNINSTALL_COMMAND}}' = $uninstallCmd
            }

            # Process templates
            $invokeTemplate = Join-Path $templatePath "Invoke-AppDeployToolkit.ps1.template"
            $templateContent = Get-Content $invokeTemplate -Raw
            $processedContent = Expand-PackageFactoryTemplate -Content $templateContent -Replacements $replacements
            $invokeOutput = Join-Path $packagePath "Invoke-AppDeployToolkit.ps1"
            $processedContent | Set-Content $invokeOutput -Encoding UTF8

            $detectTemplatePath = Join-Path $templatePath "Detect-Application.ps1.template"
            $detectTemplate = Get-Content $detectTemplatePath -Raw
            $detectProcessed = Expand-PackageFactoryTemplate -Content $detectTemplate -Replacements $replacements
            $detectOutput = Join-Path $packagePath "Detect-$($AppName.Replace(' ', '')).ps1"
            $detectProcessed | Set-Content $detectOutput -Encoding UTF8

            # Create README
            $readmeContent = Get-PackageReadmeContent -AppName $AppName -AppVendor $AppVendor -AppVersion $AppVersion `
                -AppArch $AppArch -AppLang $AppLang -Date $date -MsiFilename $MsiFilename -ExeFilename $ExeFilename

            $readmeOutput = Join-Path $packagePath "README.md"
            $readmeContent | Set-Content $readmeOutput -Encoding UTF8

            # Create Files README
            $filesReadme = Get-FilesReadmeContent -MsiFilename $MsiFilename -ExeFilename $ExeFilename
            $filesReadmePath = Join-Path $filesPath "README.md"
            $filesReadme | Set-Content $filesReadmePath -Encoding UTF8

            # Download PSADT if requested
            if ($IncludePSADT) {
                Write-Verbose "Downloading PSADT 4.1.7..."
                try {
                    Install-PSAppDeployToolkit -DestinationPath $packagePath
                }
                catch {
                    Write-Warning "PSADT download failed: $_. Package created without PSADT."
                }
            }

            Write-Verbose "Package created successfully: $packageName"

            [PSCustomObject]@{
                PSTypeName  = 'PackageFactory.Package'
                Success     = $true
                PackageName = $packageName
                PackagePath = $packagePath
                Message     = "Package created successfully"
            }
        }
        catch {
            Write-Error "Package creation failed: $_"
            [PSCustomObject]@{
                PSTypeName = 'PackageFactory.Package'
                Success    = $false
                Error      = $_.Exception.Message
            }
        }
    }
}
