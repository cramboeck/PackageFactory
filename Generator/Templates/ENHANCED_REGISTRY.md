# 📋 Enhanced Registry Key Structure - Package Factory v2.0

## Overview

All packages created by Package Factory v2.0 now write **enhanced metadata** to a centralized registry location for better tracking, reporting, and auditing.

---

## Registry Structure

### Base Path
```
HKEY_LOCAL_MACHINE\SOFTWARE\{CompanyPrefix}_IntuneAppInstall\Apps\{AppIdentifier}
```

### Example
```
HKLM:\SOFTWARE\ZSD_IntuneAppInstall\Apps\Adobe-Adobe Reader DC-24.1.0-EN-01-x64
```

### App Identifier Format
```
{Vendor}-{AppName}-{Version}-{Language}-{Revision}-{Architecture}
```

---

## Registry Values

### Complete Structure

| Value Name | Type | Description | Example |
|------------|------|-------------|---------|
| **DisplayName** | String | Full application display name | "Adobe Adobe Reader DC" |
| **DisplayVersion** | String | Application version | "24.1.0" |
| **Publisher** | String | Vendor/Publisher name | "Adobe" |
| **InstallDate** | String | Installation date (ISO 8601) | "2025-10-29" |
| **ScriptVersion** | String | PSADT script version | "1.0.0" |
| **InstalledBy** | String | Script author/creator | "Christoph Ramböck (c@ramboeck.it)" |
| **Installed** | String | Installation status flag | "Y" or "N" |
| **UninstallDate** | String | Uninstallation date (if uninstalled) | "2025-10-30" |

---

## Post-Install Registry Keys

### Created During Installation

```powershell
$regKeyPath = "HKEY_LOCAL_MACHINE\SOFTWARE\{CompanyPrefix}_IntuneAppInstall\Apps\{AppIdentifier}"

Set-ADTRegistryKey -Key $regKeyPath -Name 'DisplayName' -Value "$($adtSession.AppVendor) $($adtSession.AppName)"
Set-ADTRegistryKey -Key $regKeyPath -Name 'DisplayVersion' -Value $adtSession.AppVersion
Set-ADTRegistryKey -Key $regKeyPath -Name 'InstallDate' -Value (Get-Date -Format 'yyyy-MM-dd')
Set-ADTRegistryKey -Key $regKeyPath -Name 'Publisher' -Value $adtSession.AppVendor
Set-ADTRegistryKey -Key $regKeyPath -Name 'ScriptVersion' -Value $adtSession.AppScriptVersion
Set-ADTRegistryKey -Key $regKeyPath -Name 'InstalledBy' -Value $adtSession.AppScriptAuthor
Set-ADTRegistryKey -Key $regKeyPath -Name 'Installed' -Value "Y"
```

---

## Uninstall Behavior

### Option 1: Mark as Uninstalled (Default - Preserves History)

```powershell
Set-ADTRegistryKey -Key $regKeyPath -Name 'Installed' -Value "N"
Set-ADTRegistryKey -Key $regKeyPath -Name 'UninstallDate' -Value (Get-Date -Format 'yyyy-MM-dd')
```

**Advantages:**
- ✅ Preserves installation history
- ✅ Allows audit trail
- ✅ Can track install/uninstall cycles

### Option 2: Complete Removal (Optional)

```powershell
Remove-ADTRegistryKey -Key $regKeyPath -Recurse -ContinueOnError $true
```

**To enable:** Uncomment this line in the Uninstall section of `Invoke-AppDeployToolkit.ps1`

---

## Detection Logic

### Intune Detection Script

The detection script (`Detect-Application.ps1`) checks:

1. **Registry key exists**
2. **Installed flag is "Y"** (not "N")
3. **Version matches** expected version

```powershell
# Example detection logic
if (Test-Path -Path $detectionKey) {
    $installed = Get-ItemPropertyValue -Path $detectionKey -Name "Installed"

    if ($installed -eq "Y") {
        # App is installed
        exit 0
    } else {
        # App was uninstalled
        exit 1
    }
}
```

---

## Benefits

### 1. Centralized Tracking
```
All apps under one parent key:
HKLM:\SOFTWARE\ZSD_IntuneAppInstall\Apps\
├── Adobe-Reader DC-24.1.0-EN-01-x64
├── Microsoft-Office-365-16.0.14326-EN-01-x64
└── 7Zip-7-Zip-23.01-EN-01-x64
```

### 2. Multi-Tenant Support
```
Different company prefixes for MSPs:
HKLM:\SOFTWARE\ZSD_IntuneAppInstall\Apps\...    ← Customer ZSD
HKLM:\SOFTWARE\ACME_IntuneAppInstall\Apps\...   ← Customer ACME
HKLM:\SOFTWARE\MSP_IntuneAppInstall\Apps\...    ← Default/Internal
```

### 3. Rich Metadata
```
Query detailed information:
- Who installed it? (InstalledBy)
- When was it installed? (InstallDate)
- Which script version? (ScriptVersion)
- Is it still installed? (Installed = Y/N)
- When was it removed? (UninstallDate)
```

### 4. Easy Reporting
```powershell
# PowerShell inventory query
Get-ChildItem "HKLM:\SOFTWARE\ZSD_IntuneAppInstall\Apps" | ForEach-Object {
    Get-ItemProperty $_.PSPath | Select-Object DisplayName, DisplayVersion, InstallDate, Installed
}
```

---

## PowerShell Reporting Examples

### List All Installed Apps (Current Status)

```powershell
$companyPrefix = "ZSD"
$appsPath = "HKLM:\SOFTWARE\${companyPrefix}_IntuneAppInstall\Apps"

Get-ChildItem $appsPath | ForEach-Object {
    $props = Get-ItemProperty $_.PSPath
    if ($props.Installed -eq "Y") {
        [PSCustomObject]@{
            Application = $props.DisplayName
            Version = $props.DisplayVersion
            Publisher = $props.Publisher
            InstallDate = $props.InstallDate
            ScriptVersion = $props.ScriptVersion
        }
    }
} | Format-Table -AutoSize
```

### Find Apps Installed in Last 30 Days

```powershell
$companyPrefix = "ZSD"
$appsPath = "HKLM:\SOFTWARE\${companyPrefix}_IntuneAppInstall\Apps"
$thirtyDaysAgo = (Get-Date).AddDays(-30)

Get-ChildItem $appsPath | ForEach-Object {
    $props = Get-ItemProperty $_.PSPath
    $installDate = [DateTime]::Parse($props.InstallDate)

    if ($installDate -ge $thirtyDaysAgo -and $props.Installed -eq "Y") {
        [PSCustomObject]@{
            Application = $props.DisplayName
            InstallDate = $props.InstallDate
            Publisher = $props.Publisher
        }
    }
} | Sort-Object InstallDate -Descending
```

### Export Inventory to CSV

```powershell
$companyPrefix = "ZSD"
$appsPath = "HKLM:\SOFTWARE\${companyPrefix}_IntuneAppInstall\Apps"

Get-ChildItem $appsPath | ForEach-Object {
    Get-ItemProperty $_.PSPath
} | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, Installed, InstalledBy, ScriptVersion |
    Export-Csv -Path "C:\Temp\AppInventory.csv" -NoTypeInformation
```

### Check for Uninstalled Apps (History)

```powershell
$companyPrefix = "ZSD"
$appsPath = "HKLM:\SOFTWARE\${companyPrefix}_IntuneAppInstall\Apps"

Get-ChildItem $appsPath | ForEach-Object {
    $props = Get-ItemProperty $_.PSPath
    if ($props.Installed -eq "N") {
        [PSCustomObject]@{
            Application = $props.DisplayName
            Version = $props.DisplayVersion
            InstalledDate = $props.InstallDate
            UninstalledDate = $props.UninstallDate
        }
    }
} | Format-Table -AutoSize
```

---

## Integration with Monitoring Tools

### Microsoft Endpoint Manager (Intune)

**Custom Compliance Policy:**
```powershell
# Check if specific app is installed
$detectionKey = "HKLM:\SOFTWARE\ZSD_IntuneAppInstall\Apps\Adobe-Reader DC-24.1.0-EN-01-x64"
if (Test-Path $detectionKey) {
    $installed = Get-ItemPropertyValue -Path $detectionKey -Name "Installed"
    if ($installed -eq "Y") {
        Write-Output "Compliant"
        exit 0
    }
}
Write-Output "Non-Compliant"
exit 1
```

### PowerShell Remoting (MSP)

```powershell
# Query all clients
$computers = "PC001", "PC002", "PC003"

Invoke-Command -ComputerName $computers -ScriptBlock {
    param($prefix)
    $appsPath = "HKLM:\SOFTWARE\${prefix}_IntuneAppInstall\Apps"
    Get-ChildItem $appsPath | ForEach-Object {
        $props = Get-ItemProperty $_.PSPath
        if ($props.Installed -eq "Y") {
            [PSCustomObject]@{
                Computer = $env:COMPUTERNAME
                Application = $props.DisplayName
                Version = $props.DisplayVersion
                InstallDate = $props.InstallDate
            }
        }
    }
} -ArgumentList "ZSD" | Format-Table -AutoSize
```

### RMM Tools Integration

Most RMM tools support custom registry monitoring. Point them to:
```
HKLM:\SOFTWARE\{YourPrefix}_IntuneAppInstall\Apps
```

---

## Migration from Old Structure

### If Upgrading from v1.x

Old packages may have used simplified registry keys. To update:

1. **Re-deploy package** with v2.0 template (will create new enhanced keys)
2. Or **manually add missing values**:

```powershell
$oldKey = "HKLM:\SOFTWARE\ZSD_IntuneAppInstall\Apps\Adobe-Reader DC-24.1.0-EN-01-x64"

# Add missing values
Set-ItemProperty -Path $oldKey -Name "ScriptVersion" -Value "1.0.0"
Set-ItemProperty -Path $oldKey -Name "InstalledBy" -Value "Admin"
Set-ItemProperty -Path $oldKey -Name "Installed" -Value "Y"
```

---

## Best Practices

### ✅ DO's

1. **Use consistent Company Prefix** across all deployments
2. **Query regularly** for inventory and compliance
3. **Export to CSV** for historical tracking
4. **Preserve history** (use Installed=N instead of deletion)
5. **Document custom values** if you add more

### ❌ DON'Ts

1. **Don't modify keys manually** (unless migrating)
2. **Don't delete parent key** (SOFTWARE\{Prefix}_IntuneAppInstall)
3. **Don't use special characters** in Company Prefix
4. **Don't change structure** mid-deployment

---

## Troubleshooting

### Registry Key Not Created

**Check:**
```powershell
# Verify installation completed successfully
Get-Content "C:\Windows\Logs\Software\*AppDeployToolkit*.log" | Select-String "Creating Intune detection"
```

**Common causes:**
- Installation failed before Post-Install phase
- Insufficient permissions (need SYSTEM or Admin)
- Registry access blocked by policy

### Detection Fails Despite Installation

**Check:**
```powershell
$detectionKey = "HKLM:\SOFTWARE\ZSD_IntuneAppInstall\Apps\Adobe-Reader DC-24.1.0-EN-01-x64"

# Verify key exists
Test-Path $detectionKey

# Check Installed flag
Get-ItemPropertyValue -Path $detectionKey -Name "Installed"

# Should return "Y"
```

---

## Security Considerations

### Permissions

Registry keys are created under `HKEY_LOCAL_MACHINE`:
- ✅ Readable by all users
- ✅ Writable only by SYSTEM/Administrators
- ✅ Cannot be modified by standard users

### Sensitive Data

**Do NOT store** in registry:
- ❌ License keys
- ❌ Passwords
- ❌ API tokens
- ❌ User-specific data

**Safe to store:**
- ✅ Application metadata
- ✅ Version information
- ✅ Installation dates
- ✅ Script version

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.0.1 | 2025-10-29 | Enhanced registry structure with ScriptVersion, InstalledBy, Installed flag |
| 2.0.0 | 2025-10-29 | Added centralized registry pattern |
| 1.3.0 | 2025-10-29 | Multi-tenant support with Company Prefix |

---

**© 2025 Ramböck IT - Package Factory v2.0**

*Registry structure designed for MSP-scale deployments*
