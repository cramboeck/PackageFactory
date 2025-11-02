# 🔧 Troubleshooting Guide - Package Factory v2.0

## ❌ Common Issues & Solutions

---

## 🚨 "Import-PowerShellDataFile is not recognized"

### Problem
```
[ERROR] Failed to import Pode module: The term 'Import-PowerShellDataFile' is not recognized...
```

### Cause
**Your PowerShell version is too old.** Pode requires PowerShell 5.1 or higher.

### Check Your Version
```powershell
$PSVersionTable.PSVersion
```

**Output:**
```
Major  Minor  Build  Revision
-----  -----  -----  --------
5      1      ...    ...      ← Good! (5.1+)
5      0      ...    ...      ← Too old!
4      0      ...    ...      ← Too old!
```

### ✅ Solution 1: Install PowerShell 7+ (Recommended)

**PowerShell 7** is the modern, cross-platform version and works perfectly with Package Factory.

#### Windows
1. **Download:**
   ```
   https://aka.ms/powershell
   ```
   Or direct link:
   ```
   https://github.com/PowerShell/PowerShell/releases/latest
   ```

2. **Install:**
   - Download `PowerShell-7.x.x-win-x64.msi`
   - Run installer
   - Follow wizard

3. **Launch Package Factory with PowerShell 7:**
   ```powershell
   # Right-click Start-PackageFactory.ps1
   # Select "Run with PowerShell 7"

   # Or from PowerShell 7 console:
   pwsh.exe -File ".\Start-PackageFactory.ps1"
   ```

#### Alternative: Use winget (Windows 10/11)
```powershell
winget install Microsoft.PowerShell
```

#### Alternative: Use Chocolatey
```powershell
choco install powershell-core
```

---

### ✅ Solution 2: Update Windows PowerShell to 5.1

**Windows PowerShell 5.1** is included in:
- ✅ Windows 10 (all versions)
- ✅ Windows 11
- ✅ Windows Server 2016+

If you have an older Windows version:

#### Windows 8.1 / Server 2012 R2
1. **Download Windows Management Framework 5.1:**
   ```
   https://www.microsoft.com/download/details.aspx?id=54616
   ```

2. **Install** and **restart** your computer

3. **Verify:**
   ```powershell
   $PSVersionTable.PSVersion
   # Should show: 5.1
   ```

---

### ✅ Solution 3: Use CLI-Only Mode (Workaround)

If you can't upgrade PowerShell, use the **CLI generator** directly (from v1.3.0):

```powershell
# Navigate to v1.3.0 folder
cd PackageFactory_v1.3.0

# Create package using CLI
.\New-AutopilotPackage.ps1 `
    -AppName "Adobe Reader DC" `
    -AppVendor "Adobe" `
    -AppVersion "24.1.0" `
    -MsiFilename "AcroRead.msi" `
    -IncludePSADT
```

**Note:** This doesn't have the Web-GUI, but works with PowerShell 4.0+

---

## 🚨 "Pode module not found"

### Problem
```
[INFO] Pode module not found, attempting to download...
[ERROR] Failed to download Pode module
```

### ✅ Solution 1: Manual Installation

```powershell
# Install Pode manually
Install-Module -Name Pode -Scope CurrentUser -Force

# Then start Package Factory
.\Start-PackageFactory.ps1
```

### ✅ Solution 2: Download Pode Offline

If you don't have internet:

1. **On a computer with internet:**
   ```powershell
   Save-Module -Name Pode -Path "C:\Temp\PodeModule"
   ```

2. **Copy folder** to USB stick

3. **On target computer:**
   ```powershell
   # Copy Pode to PackageFactory
   Copy-Item "E:\PodeModule\Pode" -Destination ".\PackageFactory_v2.0_Portable\Modules\" -Recurse

   # Start Package Factory
   .\Start-PackageFactory.ps1
   ```

---

## 🚨 "Port 8080 already in use"

### Problem
```
[ERROR] Failed to start server on port 8080
```

### Cause
Another application is using port 8080.

### ✅ Solution: Use Different Port

```powershell
.\Start-PackageFactory.ps1 -Port 9090
```

Then open browser to: `http://localhost:9090`

### Find Which Process Uses Port 8080

```powershell
# Windows
netstat -ano | findstr :8080

# Stop the process
taskkill /PID <ProcessID> /F
```

---

## 🚨 "Access Denied" or "Permission Denied"

### Problem
```
[ERROR] Failed to create package: Access denied
```

### Cause
- Package Factory doesn't have write permissions to Output folder
- Antivirus blocking PowerShell scripts

### ✅ Solution 1: Run as Administrator

1. Right-click `Start-PackageFactory.bat`
2. Select "Run as administrator"

### ✅ Solution 2: Change Output Location

```powershell
# In browser, create package with different output location
# Or manually edit Config\settings.json
```

### ✅ Solution 3: Antivirus Exclusion

Add exclusion to your antivirus:
```
C:\Path\To\PackageFactory_v2.0_Portable\
```

---

## 🚨 "Execution Policy" Error

### Problem
```
... cannot be loaded because running scripts is disabled on this system.
```

### ✅ Solution: Allow Script Execution

**Option 1: Temporary (Current Session Only)**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\Start-PackageFactory.ps1
```

**Option 2: Permanent (Current User)**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

**Option 3: Run via Batch File**
```cmd
Start-PackageFactory.bat
```
(Already sets ExecutionPolicy Bypass internally)

---

## 🚨 Browser Doesn't Open Automatically

### Problem
Server starts but browser doesn't open.

### ✅ Solution: Open Manually

```
http://localhost:8080
```

Or if you used custom port:
```
http://localhost:9090
```

### Check if Server is Running

```powershell
# In browser
http://localhost:8080

# Or test with PowerShell
Invoke-WebRequest http://localhost:8080 -UseBasicParsing
```

---

## 🚨 "Failed to download PSAppDeployToolkit"

### Problem
```
[WARNING] Failed to download PSADT
```

### Cause
- No internet connection
- GitHub blocked by firewall

### ✅ Solution 1: Uncheck "Include PSADT"

In the web form:
```
☐ Automatically download and include PSAppDeployToolkit 4.1.5
```

Then **manually** add PSADT after package creation:

1. Download PSADT:
   ```
   https://github.com/PSAppDeployToolkit/PSAppDeployToolkit/releases/download/4.1.5/PSAppDeployToolkit_v4.1.5.zip
   ```

2. Extract to package:
   ```
   Output\{YourPackage}\PSAppDeployToolkit\
   ```

---

## 🚨 "Package already exists"

### Problem
```
[ERROR] Package already exists: Adobe_ReaderDC_24.1.0_x64
```

### ✅ Solution 1: Delete Old Package

Via **Web-GUI:**
1. Click "📋 Packages" button
2. Find package
3. Click "🗑️ Delete"

Via **File Explorer:**
```
Delete: Output\Adobe_ReaderDC_24.1.0_x64\
```

### ✅ Solution 2: Change Version Number

Create package with different version:
```
Version: 24.1.1  (instead of 24.1.0)
```

---

## 🚨 IntuneWinAppUtil Download Fails

### Problem
```
[ERROR] Failed to download IntuneWinAppUtil.exe
```

### ✅ Solution: Manual Download

1. **Download from GitHub:**
   ```
   https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/raw/master/IntuneWinAppUtil.exe
   ```

2. **Create Tools folder:**
   ```powershell
   New-Item -Path ".\Tools" -ItemType Directory -Force
   ```

3. **Move IntuneWinAppUtil.exe:**
   ```
   Copy to: PackageFactory_v2.0_Portable\Tools\IntuneWinAppUtil.exe
   ```

4. **Run Create-IntuneWin.ps1 again**

---

## 🚨 Web-GUI Shows Blank Page

### Problem
Browser opens but shows empty/white page.

### ✅ Solution: Check Console

1. Press **F12** in browser
2. Check **Console** tab for errors
3. If you see errors, refresh page (Ctrl+F5)

### Check if Server is Running

Look at PowerShell window - should show:
```
========================================
  Server running on: http://localhost:8080
  Press Ctrl+C to stop
========================================
```

---

## 🚨 Settings Not Saving

### Problem
Changes in Settings modal don't persist.

### ✅ Solution: Check Config File

1. **Check if writable:**
   ```powershell
   Test-Path ".\Config\settings.json"
   ```

2. **Manually edit:**
   ```json
   {
     "CompanyPrefix": "MSP",
     "DefaultArch": "x64",
     "DefaultLang": "EN",
     "IncludePSADT": true
   }
   ```

3. **Restart server**

---

## 📊 System Requirements

### Minimum Requirements
- **OS:** Windows 10/11 or Windows Server 2016+
- **PowerShell:** 5.1 or higher
- **RAM:** 512 MB
- **Disk:** 50 MB free space

### Recommended Requirements
- **OS:** Windows 10/11
- **PowerShell:** 7.4+
- **RAM:** 1 GB
- **Disk:** 100 MB free space
- **Internet:** For downloading Pode & PSADT

---

## 🆘 Still Having Issues?

### Collect Debug Information

```powershell
# PowerShell version
$PSVersionTable

# Pode version
Get-Module -ListAvailable Pode

# Check if port is free
Test-NetConnection -ComputerName localhost -Port 8080
```

### Contact Support

**Christoph Ramböck**
- Email: c@ramboeck.it
- Include: Error message, PowerShell version, Windows version

---

## 💡 Quick Reference

| Issue | Quick Fix |
|-------|-----------|
| Old PowerShell | Install PowerShell 7: https://aka.ms/powershell |
| Pode missing | `Install-Module Pode -Scope CurrentUser` |
| Port in use | `.\Start-PackageFactory.ps1 -Port 9090` |
| Execution Policy | Use `Start-PackageFactory.bat` instead |
| Browser not opening | Open manually: http://localhost:8080 |
| PSADT download fails | Uncheck "Include PSADT" in form |

---

**© 2025 Ramböck IT - Package Factory v2.0**
