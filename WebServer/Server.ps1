<#
.SYNOPSIS
    PackageFactory v2.2.1 - Pode Web Server
.DESCRIPTION
    Web server with API endpoints for package generation
.NOTES
    Author: Christoph Ramboeck (c@ramboeck.it)
    Version: 2.2.1
#>

param(
    [int]$Port = 8080,
    [string]$RootPath = (Split-Path -Parent $PSScriptRoot)
)

# Import Pode
Import-Module Pode

# Global variables
$script:RootPath = $RootPath
$script:GeneratorPath = Join-Path $RootPath "Generator"
$script:ConfigPath = Join-Path (Join-Path $RootPath "Config") "settings.json"
$script:TemplatePath = Join-Path $GeneratorPath "Templates"
$script:OutputPath = $null  # Will be set after loading config

# Logging setup
$script:LogPath = Join-Path (Join-Path $RootPath "Logs") "PackageFactory.log"
$script:LogBuffer = [System.Collections.ArrayList]::Synchronized((New-Object System.Collections.ArrayList))
$script:MaxLogBufferSize = 1000  # Keep last 1000 log entries in memory

# Ensure Logs directory exists
$logsDir = Join-Path $RootPath "Logs"
if (-not (Test-Path $logsDir)) {
    New-Item -Path $logsDir -ItemType Directory -Force | Out-Null
}

# Ensure Config directory exists
$configDir = Join-Path $RootPath "Config"
if (-not (Test-Path $configDir)) {
    New-Item -Path $configDir -ItemType Directory -Force | Out-Null
}

<#
.SYNOPSIS
    Write log entry in CMTrace format
.DESCRIPTION
    Writes log entries compatible with CMTrace.exe (Configuration Manager Trace Log Tool)
.PARAMETER Message
    The log message
.PARAMETER Level
    Log level: Info (1), Warning (2), Error (3)
.PARAMETER Component
    Component name (e.g., "PackageFactory", "CreatePackage")
.PARAMETER LogPath
    Path to log file (optional, uses script default)
#>
function Write-CMLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Info", "Warning", "Error", "Debug")]
        [string]$Level = "Info",

        [Parameter(Mandatory=$false)]
        [string]$Component = "PackageFactory",

        [Parameter(Mandatory=$false)]
        [string]$LogPath
    )

    # Get LogPath with fallback
    if (-not $LogPath) {
        $LogPath = $script:LogPath
    }

    # Safety check - if LogPath is still null, skip file logging but continue console
    if (-not $LogPath) {
        Write-Host "[$Level] $Component - $Message" -ForegroundColor Yellow
        return
    }

    # Map level to CMTrace type
    $cmType = switch ($Level) {
        "Info"    { 1 }
        "Warning" { 2 }
        "Error"   { 3 }
        "Debug"   { 1 }
        default   { 1 }
    }

    # Get caller info
    try {
        $callStack = Get-PSCallStack
        $caller = if ($callStack.Count -ge 2) {
            $callStack[1]
        } else {
            $callStack[0]
        }

        $file = if ($caller.ScriptName) { Split-Path -Leaf $caller.ScriptName } else { "Unknown" }
        $line = if ($caller.ScriptLineNumber) { $caller.ScriptLineNumber } else { 0 }
    }
    catch {
        $file = "Unknown"
        $line = 0
    }

    # Format timestamp for CMTrace
    $time = Get-Date -Format "HH:mm:ss.fff+000"
    $date = Get-Date -Format "MM-dd-yyyy"

    # Get thread ID
    $thread = [Threading.Thread]::CurrentThread.ManagedThreadId

    # Build CMTrace formatted log line
    # Format: <![LOG[Message]LOG]!><time="HH:MM:SS.fff+000" date="MM-DD-YYYY" component="Component" context="" type="1" thread="1234" file="File:Line">
    $cmLogLine = "<![LOG[$Message]LOG]!><time=`"$time`" date=`"$date`" component=`"$Component`" context=`"`" type=`"$cmType`" thread=`"$thread`" file=`"$file`:$line`">"

    # Write to log file
    try {
        $cmLogLine | Out-File -FilePath $LogPath -Append -Encoding UTF8 -ErrorAction Stop
    }
    catch {
        Write-Host "Failed to write to log file: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Add to in-memory buffer
    try {
        $logEntry = @{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Level = $Level
            Component = $Component
            Message = $Message
            File = "$file`:$line"
            CMTrace = $cmLogLine
        }

        $null = $script:LogBuffer.Add($logEntry)

        # Trim buffer if too large
        while ($script:LogBuffer.Count -gt $script:MaxLogBufferSize) {
            $script:LogBuffer.RemoveAt(0)
        }
    }
    catch {
        # Silently fail on buffer operations
    }

    # Console output with colors
    $color = switch ($Level) {
        "Info"    { "White" }
        "Warning" { "Yellow" }
        "Error"   { "Red" }
        "Debug"   { "Gray" }
        default   { "White" }
    }

    Write-Host "[$Level] $Component - $Message" -ForegroundColor $color
}

# Initialize logging
Write-CMLog -Message "PackageFactory v2.0 starting..." -Level Info -Component "Startup"

# Load or create config
function Get-Config {
    param([string]$ConfigPath)

    if (-not $ConfigPath) {
        $ConfigPath = $script:ConfigPath
    }

    try {
        if (Test-Path $ConfigPath) {
            $content = Get-Content $ConfigPath -Raw -ErrorAction Stop
            return $content | ConvertFrom-Json -ErrorAction Stop
        } else {
            # Create default config
            $defaultConfig = @{
                CompanyPrefix = "MSP"
                DefaultArch = "x64"
                DefaultLang = "EN"
                IncludePSADT = $true
                AutoOpenBrowser = $true
                OutputPath = "./Output"
            }

            # Ensure directory exists
            $configDir = Split-Path -Parent $ConfigPath
            if (-not (Test-Path $configDir)) {
                New-Item -Path $configDir -ItemType Directory -Force | Out-Null
            }

            $defaultConfig | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath -Encoding UTF8 -ErrorAction Stop
            return $defaultConfig
        }
    }
    catch {
        # Return default on error
        Write-Host "Warning: Failed to load config, using defaults: $($_.Exception.Message)" -ForegroundColor Yellow
        return @{
            CompanyPrefix = "MSP"
            DefaultArch = "x64"
            DefaultLang = "EN"
            IncludePSADT = $true
            AutoOpenBrowser = $true
            OutputPath = "./Output"
        }
    }
}

# Save config
function Set-Config {
    param(
        $Config,
        [string]$ConfigPath
    )

    if (-not $ConfigPath) {
        $ConfigPath = $script:ConfigPath
    }

    try {
        # Ensure directory exists
        $configDir = Split-Path -Parent $ConfigPath
        if (-not (Test-Path $configDir)) {
            New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        }

        $Config | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath -Encoding UTF8 -ErrorAction Stop
    }
    catch {
        Write-Host "Warning: Failed to save config: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Get current OutputPath from config (dynamically resolved)
function Get-OutputPath {
    param(
        [string]$ConfigPath,
        [string]$RootPath
    )

    if (-not $ConfigPath) {
        $ConfigPath = $script:ConfigPath
    }
    if (-not $RootPath) {
        $RootPath = $script:RootPath
    }

    $config = Get-Config -ConfigPath $ConfigPath
    $outputPathFromConfig = if ($config.OutputPath) { $config.OutputPath } else { "./Output" }

    # Handle relative vs absolute paths
    if ([System.IO.Path]::IsPathRooted($outputPathFromConfig)) {
        return $outputPathFromConfig
    } else {
        return Join-Path $RootPath $outputPathFromConfig
    }
}

# Generator function (from v1.3.0)
function New-Package {
    param(
        [string]$AppName,
        [string]$AppVendor,
        [string]$AppVersion,
        [string]$AppArch = 'x64',
        [string]$AppLang = 'EN',
        [string]$CompanyPrefix = 'MSP',
        [string]$InstallerType = 'msi',
        [string]$MsiFilename = "",
        [string]$MsiSilentParams = "/qn /norestart",
        [string]$ExeFilename = "",
        [string]$ExeSilentParams = "",
        [string]$ProcessesToClose = "",
        [bool]$IncludePSADT = $false,
        [string]$ConfigPath,
        [string]$RootPath,
        [string]$TemplatePath,
        [string]$LogPath
    )

    # Use script variables as fallback
    if (-not $ConfigPath) { $ConfigPath = $script:ConfigPath }
    if (-not $RootPath) { $RootPath = $script:RootPath }
    if (-not $TemplatePath) { $TemplatePath = $script:TemplatePath }
    if (-not $LogPath) { $LogPath = $script:LogPath }

    try {
        Write-CMLog -Message "Starting package creation: $AppVendor $AppName $AppVersion ($AppArch)" -Level Info -Component "CreatePackage" -LogPath $LogPath

        $templatePath = Join-Path $TemplatePath "Autopilot-PSADT-4x"

        if (-not (Test-Path $templatePath)) {
            Write-CMLog -Message "Template not found: $templatePath" -Level Error -Component "CreatePackage" -LogPath $LogPath
            throw "Template not found: $templatePath"
        }

        # Generate package name with Company Prefix
        $packageName = if ($CompanyPrefix) {
            "$CompanyPrefix`_$AppVendor`_$($AppName.Replace(' ', ''))`_$AppVersion`_$AppArch"
        } else {
            "$AppVendor`_$($AppName.Replace(' ', ''))`_$AppVersion`_$AppArch"
        }
        Write-CMLog -Message "Package name: $packageName" -Level Info -Component "CreatePackage" -LogPath $LogPath

        $currentOutputPath = Get-OutputPath -ConfigPath $ConfigPath -RootPath $RootPath
        $packagePath = Join-Path $currentOutputPath $packageName

        # Ensure output directory exists
        if (-not (Test-Path $currentOutputPath)) {
            Write-CMLog -Message "Creating output directory: $currentOutputPath" -Level Info -Component "CreatePackage" -LogPath $LogPath
            New-Item -Path $currentOutputPath -ItemType Directory -Force | Out-Null
        }

        # Check if package exists
        if (Test-Path $packagePath) {
            Write-CMLog -Message "Package already exists: $packageName" -Level Error -Component "CreatePackage" -LogPath $LogPath
            throw "Package already exists: $packageName"
        }

        # Create package structure
        Write-CMLog -Message "Creating package directory: $packagePath" -Level Info -Component "CreatePackage" -LogPath $LogPath
        New-Item -Path $packagePath -ItemType Directory -Force | Out-Null
        $filesPath = Join-Path $packagePath "Files"
        New-Item -Path $filesPath -ItemType Directory -Force | Out-Null
        $configPath = Join-Path $filesPath "Config"
        New-Item -Path $configPath -ItemType Directory -Force | Out-Null

        # Prepare values
        $date = Get-Date -Format "yyyy-MM-dd"
        $appRevision = "01"

        $processesFormatted = if ($ProcessesToClose) {
            ($ProcessesToClose.Split(',') | ForEach-Object { "'$($_.Trim())'" }) -join ', '
        } else {
            ""
        }

        # Determine installer commands - PSADT 4.x correct syntax
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
        } else {
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
        # `$uninstallString = Get-ADTUninstallKey -ApplicationName "$AppName" | Select-Object -ExpandProperty UninstallString
        # if (`$uninstallString) {
        #     Start-ADTProcess -FilePath `$uninstallString -ArgumentList "$silentParams" -Wait
        # }
"@
        }

        $replacements = @{
            '{{APP_NAME}}' = $AppName
            '{{APP_VENDOR}}' = $AppVendor
            '{{APP_VERSION}}' = $AppVersion
            '{{APP_ARCH}}' = $AppArch
            '{{APP_LANG}}' = $AppLang
            '{{APP_REVISION}}' = $appRevision
            '{{COMPANY_PREFIX}}' = $CompanyPrefix
            '{{DATE}}' = $date
            '{{INSTALLER_TYPE}}' = $InstallerType.ToUpper()
            '{{INSTALLER_FILE}}' = $installerFile
            '{{SILENT_PARAMS}}' = $silentParams
            '{{MSI_FILENAME}}' = $MsiFilename
            '{{EXE_FILENAME}}' = $ExeFilename
            '{{PROCESSES_TO_CLOSE}}' = $processesFormatted
            '{{INSTALL_COMMAND}}' = $installCmd
            '{{UNINSTALL_COMMAND}}' = $uninstallCmd
        }

        # Replace placeholders function
        function Replace-Placeholders {
            param([string]$Content, [hashtable]$Replacements)
            foreach ($key in $Replacements.Keys) {
                $Content = $Content -replace [regex]::Escape($key), $Replacements[$key]
            }
            return $Content
        }

        # Process templates - use Join-Path for cross-platform compatibility
        $invokeTemplate = Join-Path $templatePath "Invoke-AppDeployToolkit.ps1.template"
        $templateContent = Get-Content $invokeTemplate -Raw
        $processedContent = Replace-Placeholders -Content $templateContent -Replacements $replacements
        $invokeOutput = Join-Path $packagePath "Invoke-AppDeployToolkit.ps1"
        $processedContent | Set-Content $invokeOutput -Encoding UTF8

        $detectTemplatePath = Join-Path $templatePath "Detect-Application.ps1.template"
        $detectTemplate = Get-Content $detectTemplatePath -Raw
        $detectProcessed = Replace-Placeholders -Content $detectTemplate -Replacements $replacements
        $detectOutput = Join-Path $packagePath "Detect-$($AppName.Replace(' ', '')).ps1"
        $detectProcessed | Set-Content $detectOutput -Encoding UTF8

        # Create README
        $readmeContent = @"
# $AppName - Autopilot Deployment Package

**Vendor:** $AppVendor
**Version:** $AppVersion
**Architecture:** $AppArch
**Language:** $AppLang
**Created:** $date
**Author:** Christoph Ramböck (c@ramboeck.it)

---

## Quick Setup

### 1. Add PSAppDeployToolkit 4.1.5
``````
Download: https://github.com/PSAppDeployToolkit/PSAppDeployToolkit/releases
Extract to: PSAppDeployToolkit\
``````

### 2. Add Installer
``````
$(if ($MsiFilename) { "Copy MSI to: Files\$MsiFilename" } else { "Copy EXE to: Files\$ExeFilename" })
``````

### 3. Test
``````powershell
.\Invoke-AppDeployToolkit.ps1 -DeployMode Silent
.\Detect-$($AppName.Replace(' ', '')).ps1
``````

### 4. Create IntuneWin
``````powershell
IntuneWinAppUtil.exe -c "." -s "Invoke-AppDeployToolkit.ps1" -o "Output"
``````

---

## Intune Configuration

**Install Command:**
``````
powershell.exe -ExecutionPolicy Bypass -File "Invoke-AppDeployToolkit.ps1" -DeploymentType "Install" -DeployMode "Silent"
``````

**Uninstall Command:**
``````
powershell.exe -ExecutionPolicy Bypass -File "Invoke-AppDeployToolkit.ps1" -DeploymentType "Uninstall" -DeployMode "Silent"
``````

**Detection Method:**
- Type: Custom Script
- Script: Detect-$($AppName.Replace(' ', '')).ps1
- Run as: System

---

**© 2025 Ramböck IT - Generated by Package Factory v2.0**
"@
        $readmeOutput = Join-Path $packagePath "README.md"
        $readmeContent | Set-Content $readmeOutput -Encoding UTF8

        # Create Files README
        $filesReadme = @"
# Installation Files

## Required Files

### $(if ($MsiFilename) { $MsiFilename } else { $ExeFilename })
**Action:** Download installer and place here

### Config/ (Optional)
**Action:** Add configuration files if needed

---

**© 2025 Ramböck IT**
"@
        $filesReadmePath = Join-Path (Join-Path $packagePath "Files") "README.md"
        $filesReadme | Set-Content $filesReadmePath -Encoding UTF8

        # Copy PSADT if requested
        if ($IncludePSADT) {
            Write-CMLog -Message "Including PSADT 4.1.7..." -Level Info -Component "CreatePackage" -LogPath $LogPath
            try {
                # PSADT is stored in Generator/PSAppdeploytoolkit/PSAppDeployToolkit/
                # (User uploads complete release package, we use the toolkit subfolder)
                $psadtTemplatePath = Join-Path $RootPath "Generator\PSAppdeploytoolkit"
                $psadtSourcePath = Join-Path $psadtTemplatePath "PSAppDeployToolkit"

                # Check if source PSADT folder exists
                if (-not (Test-Path $psadtSourcePath)) {
                    throw "PSADT source folder not found: $psadtSourcePath. Please download PSADT 4.1.7 and extract to Generator\PSAppdeploytoolkit\"
                }

                # Check if PSADT module file exists
                $psadtModule = Join-Path $psadtSourcePath "PSAppDeployToolkit.psd1"
                if (-not (Test-Path $psadtModule)) {
                    throw "PSADT module not found: $psadtModule. Please ensure PSAppDeployToolkit is properly extracted."
                }

                Write-CMLog -Message "Copying PSADT from local folder: $psadtSourcePath" -Level Info -Component "CreatePackage" -LogPath $LogPath

                $psadtDestination = Join-Path $packagePath "PSAppDeployToolkit"

                # Copy PSADT folder
                Copy-Item -Path $psadtSourcePath -Destination $psadtDestination -Recurse -Force
                Write-CMLog -Message "PSADT copied to package" -Level Info -Component "CreatePackage" -LogPath $LogPath

                # Remove Invoke-AppDeployToolkit.ps1 if it exists in PSADT folder
                # (Our generated version is in the package root, not in PSAppDeployToolkit/)
                $invokeInPSADT = Join-Path $psadtDestination "Invoke-AppDeployToolkit.ps1"
                if (Test-Path $invokeInPSADT) {
                    Remove-Item $invokeInPSADT -Force
                    Write-CMLog -Message "Removed original Invoke-AppDeployToolkit.ps1 from PSADT folder (using generated version)" -Level Info -Component "CreatePackage" -LogPath $LogPath
                }

                # Copy Invoke-AppDeployToolkit.exe from parent template folder
                # This EXE is needed for Intune deployments and system context execution
                $invokeExeSource = Join-Path $psadtTemplatePath "Invoke-AppDeployToolkit.exe"
                if (Test-Path $invokeExeSource) {
                    $invokeExeDest = Join-Path $packagePath "Invoke-AppDeployToolkit.exe"
                    Copy-Item -Path $invokeExeSource -Destination $invokeExeDest -Force
                    Write-CMLog -Message "Copied Invoke-AppDeployToolkit.exe to package root" -Level Info -Component "CreatePackage" -LogPath $LogPath
                } else {
                    Write-CMLog -Message "Invoke-AppDeployToolkit.exe not found at: $invokeExeSource" -Level Warning -Component "CreatePackage" -LogPath $LogPath
                }

                Write-CMLog -Message "PSADT installation completed successfully" -Level Info -Component "CreatePackage" -LogPath $LogPath
            }
            catch {
                Write-CMLog -Message "PSADT copy failed: $($_.Exception.Message). Package created without PSADT." -Level Warning -Component "CreatePackage" -LogPath $LogPath
                # PSADT copy failed, but package was created
            }
        }

        Write-CMLog -Message "Package created successfully: $packageName at $packagePath" -Level Info -Component "CreatePackage" -LogPath $LogPath
        return @{
            Success = $true
            PackageName = $packageName
            PackagePath = $packagePath
            Message = "Package created successfully"
        }
    }
    catch {
        Write-CMLog -Message "Package creation failed: $($_.Exception.Message)" -Level Error -Component "CreatePackage" -LogPath $LogPath
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

# Load config and initialize OutputPath
$initialConfig = Get-Config
$outputPathFromConfig = if ($initialConfig.OutputPath) { $initialConfig.OutputPath } else { "./Output" }

# Handle relative vs absolute paths
if ([System.IO.Path]::IsPathRooted($outputPathFromConfig)) {
    $script:OutputPath = $outputPathFromConfig
} else {
    $script:OutputPath = Join-Path $RootPath $outputPathFromConfig
}

# Ensure Output directory exists
if (-not (Test-Path $script:OutputPath)) {
    New-Item -Path $script:OutputPath -ItemType Directory -Force | Out-Null
    Write-Host "Created output directory: $script:OutputPath" -ForegroundColor Cyan
}

Write-Host "Output path: $script:OutputPath" -ForegroundColor Cyan

# Start Pode Server
Start-PodeServer {
    # Listen on all interfaces (0.0.0.0) for Docker compatibility
    # Use * which translates to 0.0.0.0 in Pode
    Add-PodeEndpoint -Address * -Port $Port -Protocol Http

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Server running on: http://0.0.0.0:$Port" -ForegroundColor Green
    Write-Host "  Access via: http://localhost:$Port" -ForegroundColor Green
    Write-Host "  Press Ctrl+C to stop" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""

    # Open browser automatically
    Start-Sleep -Seconds 1
    try {
        Start-Process "http://localhost:$Port"
    } catch {
        # Browser opening failed, user can open manually
    }

    # Serve static files - cross-platform paths
    $webServerPath = Join-Path $RootPath "WebServer"
    $publicPath = Join-Path $webServerPath "Public"

    # Only add static routes for directories that actually exist
    $cssPath = Join-Path $publicPath "css"
    if (Test-Path $cssPath) {
        Add-PodeStaticRoute -Path '/css' -Source $cssPath
    }

    $jsPath = Join-Path $publicPath "js"
    if (Test-Path $jsPath) {
        Add-PodeStaticRoute -Path '/js' -Source $jsPath
    }

    $imgPath = Join-Path $publicPath "img"
    if (Test-Path $imgPath) {
        Add-PodeStaticRoute -Path '/img' -Source $imgPath
    }

    # Root page
    Add-PodeRoute -Method Get -Path '/' -ScriptBlock {
        $webServerPath = Join-Path $using:RootPath "WebServer"
        $publicPath = Join-Path $webServerPath "Public"
        $htmlPath = Join-Path $publicPath "index.html"
        Write-PodeHtmlResponse -Value (Get-Content $htmlPath -Raw)
    }

    # API: Get config
    Add-PodeRoute -Method Get -Path '/api/config' -ScriptBlock {
        $config = Get-Config -ConfigPath $using:ConfigPath
        Write-PodeJsonResponse -Value $config
    }

    # API: Save config
    Add-PodeRoute -Method Post -Path '/api/config' -ScriptBlock {
        $config = $WebEvent.Data
        Set-Config -Config $config -ConfigPath $using:ConfigPath
        Write-CMLog -Message "Configuration saved" -Level Info -Component "Config" -LogPath $using:LogPath
        Write-PodeJsonResponse -Value @{ success = $true; message = "Configuration saved" }
    }

    # API: Get version info
    Add-PodeRoute -Method Get -Path '/api/version' -ScriptBlock {
        $rootPath = $using:RootPath
        $versionFile = Join-Path $rootPath "VERSION.txt"
        $version = "2.2.1"
        $buildDate = "2025-11-02"

        if (Test-Path $versionFile) {
            $content = Get-Content $versionFile -Raw
            if ($content -match 'PackageFactory v([\d\.]+)') {
                $version = $Matches[1]
            }
            if ($content -match 'Build Date: ([\d\-]+)') {
                $buildDate = $Matches[1]
            }
        }

        Write-PodeJsonResponse -Value @{
            version = $version
            buildDate = $buildDate
            fullVersion = "PackageFactory v$version"
        }
    }

    # API: Get logs
    Add-PodeRoute -Method Get -Path '/api/logs' -ScriptBlock {
        $limit = $WebEvent.Query['limit']
        $level = $WebEvent.Query['level']
        $logPath = $using:LogPath

        $logs = @()

        # Read logs from file if it exists
        if (Test-Path $logPath) {
            try {
                $logContent = Get-Content -Path $logPath -Raw -ErrorAction SilentlyContinue

                if ($logContent) {
                    # Parse CMTrace log format
                    # Format: <![LOG[Message]LOG]!><time="HH:MM:SS.mmm+000" date="MM-DD-YYYY" component="Component" context="" type="1" thread="1234" file="File:Line">
                    $logLines = $logContent -split "`n" | Where-Object { $_ -match '<!\[LOG\[' }

                    foreach ($line in $logLines) {
                        if ($line -match '<!\[LOG\[(.*?)\]LOG\]!><time="(.*?)" date="(.*?)" component="(.*?)".*?type="(.*?)".*?file="(.*?)"') {
                            $message = $Matches[1]
                            $time = $Matches[2]
                            $date = $Matches[3]
                            $component = $Matches[4]
                            $type = $Matches[5]
                            $file = $Matches[6]

                            # Map type to level
                            $levelText = switch ($type) {
                                "1" { "Info" }
                                "2" { "Warning" }
                                "3" { "Error" }
                                default { "Info" }
                            }

                            $logs += @{
                                Timestamp = "$date $time"
                                Level = $levelText
                                Component = $component
                                Message = $message
                                File = $file
                            }
                        }
                    }
                }
            }
            catch {
                Write-Warning "Failed to read log file: $_"
            }
        }

        # Filter by level if specified
        if ($level -and $level -ne 'All') {
            $logs = $logs | Where-Object { $_.Level -eq $level }
        }

        # Limit results if specified
        if ($limit) {
            $limitNum = [int]$limit
            if ($logs.Count -gt $limitNum) {
                $logs = $logs | Select-Object -Last $limitNum
            }
        }

        # Ensure logs is still an array
        if (-not $logs) {
            $logs = @()
        }

        Write-PodeJsonResponse -Value @{
            success = $true
            count = if ($logs) { $logs.Count } else { 0 }
            logs = if ($logs) { $logs } else { @() }
        }
    }

    # API: Get log file
    Add-PodeRoute -Method Get -Path '/api/logs/download' -ScriptBlock {
        $logPath = $using:LogPath

        if (Test-Path $logPath) {
            $content = Get-Content $logPath -Raw
            Set-PodeResponseAttachment -Path $logPath -ContentType 'text/plain'
        } else {
            Write-PodeJsonResponse -Value @{ success = $false; error = "Log file not found" } -StatusCode 404
        }
    }

    # API: Clear logs
    Add-PodeRoute -Method Delete -Path '/api/logs' -ScriptBlock {
        # Clear in-memory buffer
        $logBuffer = $using:LogBuffer
        $logBuffer.Clear()

        # Clear log file
        if (Test-Path $using:LogPath) {
            Clear-Content $using:LogPath
        }

        Write-CMLog -Message "Logs cleared by user" -Level Info -Component "Logs" -LogPath $using:LogPath
        Write-PodeJsonResponse -Value @{ success = $true; message = "Logs cleared" }
    }

    # API: Create package
    Add-PodeRoute -Method Post -Path '/api/create-package' -ScriptBlock {
        $data = $WebEvent.Data

        $result = New-Package `
            -AppName $data.appName `
            -AppVendor $data.appVendor `
            -AppVersion $data.appVersion `
            -AppArch $data.appArch `
            -AppLang $data.appLang `
            -CompanyPrefix $data.companyPrefix `
            -InstallerType $data.installerType `
            -MsiFilename $data.msiFilename `
            -MsiSilentParams $data.msiSilentParams `
            -ExeFilename $data.exeFilename `
            -ExeSilentParams $data.exeSilentParams `
            -ProcessesToClose $data.processesToClose `
            -IncludePSADT $data.includePSADT `
            -ConfigPath $using:ConfigPath `
            -RootPath $using:RootPath `
            -TemplatePath $using:TemplatePath `
            -LogPath $using:LogPath

        Write-PodeJsonResponse -Value $result
    }

    # API: List packages
    Add-PodeRoute -Method Get -Path '/api/packages' -ScriptBlock {
        $packages = @()

        # Get current OutputPath dynamically from config
        $currentOutputPath = Get-OutputPath -ConfigPath $using:ConfigPath -RootPath $using:RootPath

        if (Test-Path $currentOutputPath) {
            Get-ChildItem -Path $currentOutputPath -Directory | ForEach-Object {
                $readmePath = Join-Path $_.FullName "README.md"
                $created = $_.CreationTime.ToString("yyyy-MM-dd HH:mm")

                $packages += @{
                    name = $_.Name
                    path = $_.FullName
                    created = $created
                    hasReadme = Test-Path $readmePath
                }
            }
        }

        Write-PodeJsonResponse -Value $packages
    }

    # API: Get package details
    Add-PodeRoute -Method Get -Path '/api/packages/:name/details' -ScriptBlock {
        $packageName = $WebEvent.Parameters['name']

        # Get current OutputPath dynamically from config
        $currentOutputPath = Get-OutputPath -ConfigPath $using:ConfigPath -RootPath $using:RootPath
        $packagePath = Join-Path $currentOutputPath $packageName

        if (-not (Test-Path $packagePath)) {
            Write-PodeJsonResponse -Value @{ success = $false; error = "Package not found" } -StatusCode 404
            return
        }

        # Read Invoke-AppDeployToolkit.ps1 to extract metadata
        $deployScriptPath = Join-Path $packagePath "Invoke-AppDeployToolkit.ps1"
        $detectScriptPath = Get-ChildItem -Path $packagePath -Filter "Detect-*.ps1" | Select-Object -First 1

        if (-not (Test-Path $deployScriptPath)) {
            Write-PodeJsonResponse -Value @{ success = $false; error = "Deployment script not found" } -StatusCode 404
            return
        }

        # Parse deployment script for metadata
        $deployContent = Get-Content -Path $deployScriptPath -Raw

        # Extract variables using regex
        $appVendor = if ($deployContent -match "AppVendor\s*=\s*'([^']+)'") { $Matches[1] } else { "" }
        $appName = if ($deployContent -match "AppName\s*=\s*'([^']+)'") { $Matches[1] } else { "" }
        $appVersion = if ($deployContent -match "AppVersion\s*=\s*'([^']+)'") { $Matches[1] } else { "" }
        $appArch = if ($deployContent -match "AppArch\s*=\s*'([^']+)'") { $Matches[1] } else { "" }
        $appLang = if ($deployContent -match "AppLang\s*=\s*'([^']+)'") { $Matches[1] } else { "" }
        $appRevision = if ($deployContent -match "AppRevision\s*=\s*'([^']+)'") { $Matches[1] } else { "" }
        $companyPrefix = if ($deployContent -match "CompanyPrefix\s*=\s*'([^']+)'") { $Matches[1] } else { "" }

        # Extract installer type and parameters
        $installerType = "unknown"
        $installerFilename = ""

        if ($deployContent -match "Start-ADTMsiProcess") {
            $installerType = "msi"
            # Extract MSI filename from: Join-Path -Path $adtSession.DirFiles -ChildPath "filename.msi"
            if ($deployContent -match 'Join-Path -Path \$adtSession\.DirFiles -ChildPath "([^"]+\.msi)"') {
                $installerFilename = $Matches[1]
            }
        }
        elseif ($deployContent -match "Start-ADTProcess") {
            $installerType = "exe"
            # Extract EXE filename from: Join-Path -Path $adtSession.DirFiles -ChildPath "filename.exe"
            if ($deployContent -match 'Join-Path -Path \$adtSession\.DirFiles -ChildPath "([^"]+\.exe)"') {
                $installerFilename = $Matches[1]
            }
        }

        # Read detection script if exists
        $detectionRule = ""
        $detectionKey = ""
        if ($detectScriptPath) {
            $detectContent = Get-Content -Path $detectScriptPath.FullName -Raw
            $detectionRule = $detectContent
        }

        # Build detection key from extracted values
        if ($appVendor -and $appName -and $appVersion) {
            $appIdentifier = "$appVendor-$appName-$appVersion-$appLang-$appRevision-$appArch"
            $appIdentifier = $appIdentifier -replace '\s+', ''  # Remove spaces
            $detectionKey = "HKLM:\SOFTWARE\${companyPrefix}_IntuneAppInstall\Apps\$appIdentifier"
        }

        # Build install/uninstall commands
        $installCmd = "powershell.exe -ExecutionPolicy Bypass -File `"Invoke-AppDeployToolkit.ps1`" -DeploymentType `"Install`" -DeployMode `"Silent`""
        $uninstallCmd = "powershell.exe -ExecutionPolicy Bypass -File `"Invoke-AppDeployToolkit.ps1`" -DeploymentType `"Uninstall`" -DeployMode `"Silent`""

        # Get README content
        $readmePath = Join-Path $packagePath "README.md"
        $readmeContent = ""
        if (Test-Path $readmePath) {
            $readmeContent = Get-Content -Path $readmePath -Raw
        }

        $packageDetails = @{
            success = $true
            package = @{
                name = $packageName
                path = $packagePath
                vendor = $appVendor
                appName = $appName
                version = $appVersion
                architecture = $appArch
                language = $appLang
                revision = $appRevision
                companyPrefix = $companyPrefix
                installerType = $installerType
                installerFilename = $installerFilename
                installCommand = $installCmd
                uninstallCommand = $uninstallCmd
                detectionKey = $detectionKey
                detectionScript = if ($detectScriptPath) { $detectScriptPath.Name } else { "" }
                detectionRule = $detectionRule
                readme = $readmeContent
            }
        }

        Write-PodeJsonResponse -Value $packageDetails
    }

    # API: Delete package
    Add-PodeRoute -Method Delete -Path '/api/packages/:name' -ScriptBlock {
        $packageName = $WebEvent.Parameters['name']

        # Get current OutputPath dynamically from config
        $currentOutputPath = Get-OutputPath -ConfigPath $using:ConfigPath -RootPath $using:RootPath
        $packagePath = Join-Path $currentOutputPath $packageName

        if (Test-Path $packagePath) {
            Remove-Item -Path $packagePath -Recurse -Force
            Write-PodeJsonResponse -Value @{ success = $true; message = "Package deleted" }
        } else {
            Write-PodeJsonResponse -Value @{ success = $false; error = "Package not found" } -StatusCode 404
        }
    }

    # API: Validate package
    Add-PodeRoute -Method Get -Path '/api/packages/:name/validate' -ScriptBlock {
        $packageName = $WebEvent.Parameters['name']

        # Get current OutputPath dynamically from config
        $currentOutputPath = Get-OutputPath -ConfigPath $using:ConfigPath -RootPath $using:RootPath
        $packagePath = Join-Path $currentOutputPath $packageName

        if (-not (Test-Path $packagePath)) {
            Write-PodeJsonResponse -Value @{
                success = $false
                valid = $false
                status = "error"
                message = "Package not found"
            } -StatusCode 404
            return
        }

        # Read deployment script to get installer filename
        $deployScriptPath = Join-Path $packagePath "Invoke-AppDeployToolkit.ps1"
        $filesPath = Join-Path $packagePath "Files"

        $validation = @{
            success = $true
            valid = $true
            status = "valid"
            messages = @()
            warnings = @()
            errors = @()
            filesFound = @()
        }

        # Check if deployment script exists
        if (-not (Test-Path $deployScriptPath)) {
            $validation.valid = $false
            $validation.status = "error"
            $validation.errors += "Deployment script not found"
        }

        # Check if Files folder exists
        if (-not (Test-Path $filesPath)) {
            $validation.valid = $false
            $validation.status = "error"
            $validation.errors += "Files folder not found"
        } else {
            # Get list of files in Files folder
            $filesInFolder = Get-ChildItem -Path $filesPath -File -Recurse | Select-Object -ExpandProperty Name
            $validation.filesFound = $filesInFolder

            # Extract expected installer filename from script
            if (Test-Path $deployScriptPath) {
                $deployContent = Get-Content -Path $deployScriptPath -Raw

                $expectedFilename = $null
                if ($deployContent -match 'Join-Path -Path \$adtSession\.DirFiles -ChildPath "([^"]+\.(msi|exe))"') {
                    $expectedFilename = $Matches[1]
                }

                if ($expectedFilename) {
                    $installerPath = Join-Path $filesPath $expectedFilename

                    if (-not (Test-Path $installerPath)) {
                        $validation.valid = $false
                        $validation.status = "warning"
                        $validation.warnings += "Expected installer not found: $expectedFilename"

                        # Suggest similar files
                        $similarFiles = $filesInFolder | Where-Object {
                            $_ -like "*.$($expectedFilename.Split('.')[-1])"
                        }

                        if ($similarFiles) {
                            $validation.warnings += "Found similar files: $($similarFiles -join ', ')"
                        }
                    } else {
                        $validation.messages += "Installer found: $expectedFilename"
                    }
                } else {
                    $validation.warnings += "Could not determine expected installer filename"
                }
            }

            # Check if Files folder is empty
            if ($filesInFolder.Count -eq 0) {
                $validation.valid = $false
                $validation.status = "warning"
                $validation.warnings += "Files folder is empty - no installer files found"
            }
        }

        # Set final status
        if ($validation.errors.Count -gt 0) {
            $validation.status = "error"
        } elseif ($validation.warnings.Count -gt 0) {
            $validation.status = "warning"
        } else {
            $validation.status = "valid"
        }

        Write-PodeJsonResponse -Value $validation
    }

    # API: Get templates
    Add-PodeRoute -Method Get -Path '/api/templates' -ScriptBlock {
        $templates = @()

        if (Test-Path $using:TemplatePath) {
            Get-ChildItem -Path $using:TemplatePath -Directory | ForEach-Object {
                $templates += @{
                    name = $_.Name
                    path = $_.FullName
                }
            }
        }

        Write-PodeJsonResponse -Value $templates
    }
}
