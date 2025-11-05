<#
.SYNOPSIS
    Creates an .intunewin package from a PackageFactory package
.DESCRIPTION
    Uses IntuneWinAppUtil.exe to create an .intunewin package suitable for Microsoft Intune deployment.
    Generates a deployment guide with install/uninstall commands and detection rules.
.PARAMETER PackagePath
    Path to the source package directory
.PARAMETER IntuneWinAppUtilPath
    Path to IntuneWinAppUtil.exe (defaults to Tools/IntuneWinAppUtil.exe)
.PARAMETER SetupFile
    Setup file to use (defaults to Invoke-AppDeployToolkit.exe)
.EXAMPLE
    New-IntuneWinPackage -PackagePath "Output/Adobe_Reader_2024.1.0_x64"
#>
function New-IntuneWinPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackagePath,

        [Parameter(Mandatory = $false)]
        [string]$IntuneWinAppUtilPath,

        [Parameter(Mandatory = $false)]
        [string]$SetupFile = "Invoke-AppDeployToolkit.exe"
    )

    try {
        # Resolve paths
        if (-not [System.IO.Path]::IsPathRooted($PackagePath)) {
            $PackagePath = Join-Path (Get-Location) $PackagePath
        }

        # Validate package path exists
        if (-not (Test-Path $PackagePath)) {
            throw "Package path not found: $PackagePath"
        }

        # Get package name
        $packageName = Split-Path $PackagePath -Leaf

        # Determine IntuneWinAppUtil.exe path
        if (-not $IntuneWinAppUtilPath) {
            $rootPath = Get-PackageFactoryRoot
            $IntuneWinAppUtilPath = Join-Path $rootPath "Tools\IntuneWinAppUtil.exe"
        }

        # Validate IntuneWinAppUtil.exe exists
        if (-not (Test-Path $IntuneWinAppUtilPath)) {
            throw "IntuneWinAppUtil.exe not found at: $IntuneWinAppUtilPath. Please download from https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool and place in Tools directory."
        }

        # Validate setup file exists
        $setupFilePath = Join-Path $PackagePath $SetupFile
        if (-not (Test-Path $setupFilePath)) {
            throw "Setup file not found: $setupFilePath. Make sure the package includes PSADT with Invoke-AppDeployToolkit.exe"
        }

        # Create Intune output directory
        $intuneOutputPath = Join-Path $PackagePath "Intune"
        if (-not (Test-Path $intuneOutputPath)) {
            New-Item -Path $intuneOutputPath -ItemType Directory -Force | Out-Null
            Write-Verbose "Created Intune output directory: $intuneOutputPath"
        }

        Write-Verbose "Creating .intunewin package for: $packageName"
        Write-Verbose "Source: $PackagePath"
        Write-Verbose "Output: $intuneOutputPath"
        Write-Verbose "Setup file: $SetupFile"

        # Build IntuneWinAppUtil command
        # Syntax: IntuneWinAppUtil.exe -c <source_folder> -s <setup_file> -o <output_folder> -q
        $arguments = @(
            "-c", "`"$PackagePath`""
            "-s", "`"$SetupFile`""
            "-o", "`"$intuneOutputPath`""
            "-q"  # Quiet mode
        )

        Write-Verbose "Executing: $IntuneWinAppUtilPath $($arguments -join ' ')"

        # Execute IntuneWinAppUtil
        $process = Start-Process -FilePath $IntuneWinAppUtilPath `
            -ArgumentList $arguments `
            -Wait `
            -PassThru `
            -NoNewWindow `
            -RedirectStandardOutput (Join-Path $env:TEMP "intunewin_stdout.txt") `
            -RedirectStandardError (Join-Path $env:TEMP "intunewin_stderr.txt")

        if ($process.ExitCode -ne 0) {
            $stdout = Get-Content (Join-Path $env:TEMP "intunewin_stdout.txt") -Raw -ErrorAction SilentlyContinue
            $stderr = Get-Content (Join-Path $env:TEMP "intunewin_stderr.txt") -Raw -ErrorAction SilentlyContinue
            throw "IntuneWinAppUtil failed with exit code $($process.ExitCode). STDOUT: $stdout STDERR: $stderr"
        }

        # Find generated .intunewin file
        $intunewinFile = Get-ChildItem -Path $intuneOutputPath -Filter "*.intunewin" | Select-Object -First 1

        if (-not $intunewinFile) {
            throw "No .intunewin file was created in: $intuneOutputPath"
        }

        Write-Verbose ".intunewin package created: $($intunewinFile.FullName)"

        # Generate deployment guide
        $deploymentGuide = Get-IntuneDeploymentGuide -PackagePath $PackagePath -PackageName $packageName
        $deploymentGuidePath = Join-Path $intuneOutputPath "DEPLOYMENT-GUIDE.md"
        $deploymentGuide | Set-Content $deploymentGuidePath -Encoding UTF8

        Write-Verbose "Deployment guide created: $deploymentGuidePath"

        # Return success
        [PSCustomObject]@{
            PSTypeName       = 'PackageFactory.IntuneWinPackage'
            Success          = $true
            PackageName      = $packageName
            IntuneWinFile    = $intunewinFile.FullName
            IntuneWinName    = $intunewinFile.Name
            DeploymentGuide  = $deploymentGuidePath
            OutputPath       = $intuneOutputPath
            Message          = "IntuneWin package created successfully"
        }
    }
    catch {
        Write-Error "Failed to create IntuneWin package: $_"
        [PSCustomObject]@{
            PSTypeName  = 'PackageFactory.IntuneWinPackage'
            Success     = $false
            PackageName = $packageName
            Error       = $_.Exception.Message
        }
    }
}

function Get-IntuneDeploymentGuide {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackagePath,

        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )

    # Try to extract metadata from Detection.ps1
    $detectionScript = Join-Path $PackagePath "Detection.ps1"
    $detectionKey = "Unknown"

    if (Test-Path $detectionScript) {
        $detectionContent = Get-Content $detectionScript -Raw
        if ($detectionContent -match 'HKLM:\\SOFTWARE\\([^"]+)"') {
            $detectionKey = "HKLM:\SOFTWARE\$($Matches[1])"
        }
    }

    # Extract metadata from Invoke-AppDeployToolkit.ps1 if it exists
    $invokeScript = Join-Path $PackagePath "Invoke-AppDeployToolkit.ps1"
    $appVendor = "Unknown"
    $appName = "Unknown"
    $appVersion = "Unknown"

    if (Test-Path $invokeScript) {
        $invokeContent = Get-Content $invokeScript -Raw
        if ($invokeContent -match '\$appVendor\s*=\s*[''"]([^''"]+)[''"]') {
            $appVendor = $Matches[1]
        }
        if ($invokeContent -match '\$appName\s*=\s*[''"]([^''"]+)[''"]') {
            $appName = $Matches[1]
        }
        if ($invokeContent -match '\$appVersion\s*=\s*[''"]([^''"]+)[''"]') {
            $appVersion = $Matches[1]
        }
    }

    # Generate deployment guide
    @"
# Intune Deployment Guide

**Package:** $PackageName
**Application:** $appVendor $appName $appVersion
**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

---

## 📦 Package Information

This package was created using **PackageFactory** and is ready for deployment via Microsoft Intune.

### What's Included

- ✅ Application installer files
- ✅ PSAppDeployToolkit 4.1.7
- ✅ Installation/Uninstallation scripts
- ✅ Detection script

---

## 🚀 Intune Configuration

### 1. Upload Package

1. Navigate to **Microsoft Intune Admin Center** → **Apps** → **Windows**
2. Click **+ Add** → Select **Windows app (Win32)**
3. Click **Select app package file**
4. Upload the `.intunewin` file from this directory

### 2. App Information

| Field | Value |
|-------|-------|
| **Name** | $appVendor $appName |
| **Description** | Automated deployment package for $appVendor $appName $appVersion |
| **Publisher** | $appVendor |
| **App Version** | $appVersion |

### 3. Program Configuration

#### Install Command
``````
Invoke-AppDeployToolkit.exe -DeploymentType Install
``````

#### Uninstall Command
``````
Invoke-AppDeployToolkit.exe -DeploymentType Uninstall
``````

#### Install Behavior
- **Install behavior:** System
- **Device restart behavior:** Determine behavior based on return codes

### 4. Requirements

| Setting | Value |
|---------|-------|
| **Operating system architecture** | x64, x86 |
| **Minimum operating system** | Windows 10 1607 |

### 5. Detection Rules

**Rule type:** Registry

| Field | Value |
|-------|-------|
| **Key path** | ``$detectionKey`` |
| **Value name** | ``InstallDate`` |
| **Detection method** | String comparison |
| **Operator** | Equals |
| **Value** | ``(Current Date)`` or **Key exists** |

**Alternative:** Use custom detection script (Detection.ps1 included in package)

### 6. Return Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1641 | Success (Reboot initiated) |
| 3010 | Success (Reboot required) |
| 1618 | Installation already in progress |
| 1603 | Fatal error |

---

## 📋 Deployment Process

### Standard Deployment

1. **Assign** the application to target groups (Users or Devices)
2. **Assignment type:**
   - **Available:** Users can install from Company Portal
   - **Required:** Automatic installation on assigned devices
3. **Monitor** deployment status in Intune Reports

### Testing Recommendations

1. Deploy as **Available** to a test group first
2. Verify installation on test devices
3. Check detection rules are working
4. Review logs: ``C:\Windows\Logs\Software\*``
5. Expand to production groups

---

## 🔍 Troubleshooting

### Log Locations

- **Intune Management Extension:** ``C:\ProgramData\Microsoft\IntuneManagementExtension\Logs``
- **Application Logs:** ``C:\Windows\Logs\Software\<PackageName>``
- **CMTrace Logs:** Download CMTrace from package details page

### Common Issues

| Issue | Solution |
|-------|----------|
| Installation fails | Check install command and log files |
| Detection not working | Verify registry key path and value |
| Reboot required | Ensure return code 3010 is configured |
| Files missing | Verify .intunewin package includes all files |

### Support

For issues with the package creation or deployment scripts, check the PackageFactory documentation.

---

**Created with PackageFactory v2.2.1**
**© 2025 Ramböck IT**
"@
}
