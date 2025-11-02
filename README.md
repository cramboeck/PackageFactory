# PackageFactory

[![CI](https://github.com/cramboeck/PackageFactory/workflows/CI/badge.svg)](https://github.com/cramboeck/PackageFactory/actions)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PackageFactory.svg)](https://www.powershellgallery.com/packages/PackageFactory)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207.x-blue.svg)](https://github.com/PowerShell/PowerShell)

**Professional MSP Package Generator for Microsoft Intune Deployments**

PackageFactory is a comprehensive solution for MSPs and IT professionals to create, manage, and deploy application packages for Microsoft Intune. It combines the power of PSAppDeployToolkit with an intuitive web-based interface and robust PowerShell module.

---

## Features

### Core Capabilities
- **PowerShell Module** - Professional module structure with cmdlets for automation
- **Web-Based GUI** - Modern, responsive browser interface
- **REST API** - Programmable package creation and management
- **Package Manager** - View, manage, and delete created packages
- **Multi-Tenant Support** - Company prefix for MSP environments
- **Auto PSADT Download** - Optional automatic PSAppDeployToolkit integration
- **Template System** - Flexible and extensible template engine
- **Docker Support** - Containerized deployment option

### Integration
- PSAppDeployToolkit 4.1.5 integration
- Microsoft Intune ready packages
- Autopilot deployment support
- Detection script generation
- Silent installation support (MSI/EXE)

---

## Quick Start

### Installation

#### Option 1: PowerShell Gallery (Recommended)
```powershell
Install-Module -Name PackageFactory -Scope CurrentUser
```

#### Option 2: Git Clone
```bash
git clone https://github.com/cramboeck/PackageFactory.git
cd PackageFactory
Import-Module ./src/PackageFactory.psd1
```

#### Option 3: Portable Mode
Download the latest release ZIP, extract, and run `Start-PackageFactory.bat`

### Basic Usage

#### Using PowerShell Module
```powershell
# Import module
Import-Module PackageFactory

# Create a package
New-AutopilotPackage -AppName "7-Zip" -AppVendor "Igor Pavlov" -AppVersion "23.01" -MsiFilename "7z2301-x64.msi"

# List packages
Get-PackageFactoryPackage

# Remove a package
Remove-PackageFactoryPackage -Name "MSP_IgorPavlov_7-Zip_23.01_x64"
```

#### Using Web GUI
```powershell
# Start web server
Start-PackageFactoryServer

# Or use the portable launcher
.\Start-PackageFactory.bat
```

Browser opens automatically at `http://localhost:8080`

---

## Project Structure

```
PackageFactory/
│
├── 🚀 Start-PackageFactory.bat      ← Double-click to start!
├── 🚀 Start-PackageFactory.ps1      ← PowerShell launcher
├── 🔧 Setup-PortableMode.bat        ← Setup for offline use
├── 🔧 Setup-PortableMode.ps1        ← Pode module downloader
│
├── 🐳 Docker-Rebuild.bat            ← Rebuild Docker with latest code
├── 🐳 Docker-Rebuild.ps1            ← Docker cleanup & rebuild
├── 🐳 Start-Docker-Quick.bat        ← Quick Docker start
│
├── 📁 Modules/                      ← Embedded dependencies
│   └── Pode/                        (Auto-downloaded if missing)
│
├── 📁 WebServer/
│   ├── Server.ps1                   ← Web server + API
│   └── Public/                      ← Web GUI files
│       ├── index.html
│       ├── css/styles.css
│       └── js/app.js
│
├── 📁 Generator/
│   └── Templates/                   ← Package templates
│       └── Autopilot-PSADT-4x/
│
├── 📁 Output/                       ← Created packages
│
├── 📁 Config/
│   └── settings.json                ← Configuration
│
└── 📄 README.md                     ← You are here!
```

---

## 🚀 Quick Start

### Option A: Auto-Setup (Recommended)
**First-time setup with internet connection**

1. **Extract** the ZIP file
2. **Double-click**: `Start-PackageFactory.bat`
3. Pode module downloads automatically (if not present)
4. **Browser opens** → Fill form → Create Package!

**That's it! 🎉**

### Option B: Full Portable Mode (Offline-Ready)
**For air-gapped or offline environments**

1. **Extract** the ZIP file
2. **Run once with internet**: `Setup-PortableMode.bat`
   - Downloads Pode module to Modules/ folder
   - Makes package truly portable
3. **Copy folder** to USB/offline location
4. **Double-click**: `Start-PackageFactory.bat` (works offline now!)

**Perfect for field work! 📦**

---

## 💡 Use Cases

### 1. **MSP Technician on the Road** 👨‍💼
```
USB Stick → Customer Site → Create Packages → Take Home
```

### 2. **Team Collaboration** 👥
```
Network Share → Multiple Technicians → Shared Output
```

### 3. **Air-Gapped Environments** 🔒
```
Secure Network → No Internet → Works Offline*
(*except PSADT auto-download)
```

### 4. **Customer Demos** 🎪
```
Show at Customer → No Installation → Professional
```

### 5. **Multi-Site MSPs** 🌍
```
Same Version Everywhere → Consistency Guaranteed
```

---

## 🎯 Features in Detail

### Web GUI
- **Modern Interface** - Gradient design, responsive layout
- **Form Validation** - Real-time feedback
- **Result Display** - Success/error messages with details
- **Keyboard Shortcuts** - ESC to close modals

### API Endpoints

#### GET /api/config
Get current configuration
```json
{
  "CompanyPrefix": "MSP",
  "DefaultArch": "x64",
  "DefaultLang": "EN",
  "IncludePSADT": true
}
```

#### POST /api/config
Save configuration
```json
{
  "CompanyPrefix": "ACME",
  "DefaultArch": "x64",
  "DefaultLang": "DE",
  "IncludePSADT": false
}
```

#### POST /api/create-package
Create new package
```json
{
  "appVendor": "Adobe",
  "appName": "Adobe Reader DC",
  "appVersion": "24.1.0",
  "companyPrefix": "ZSD",
  "appArch": "x64",
  "appLang": "EN",
  "msiFilename": "AcroRead.msi",
  "processesToClose": "AcroRd32",
  "includePSADT": true
}
```

Response:
```json
{
  "Success": true,
  "PackageName": "Adobe_AdobeReaderDC_24.1.0_x64",
  "PackagePath": "C:\\...\\Output\\Adobe_AdobeReaderDC_24.1.0_x64",
  "Message": "Package created successfully"
}
```

#### GET /api/packages
List all created packages
```json
[
  {
    "name": "Adobe_AdobeReaderDC_24.1.0_x64",
    "path": "C:\\...\\Output\\Adobe_AdobeReaderDC_24.1.0_x64",
    "created": "2025-10-29 14:30",
    "hasReadme": true
  }
]
```

#### DELETE /api/packages/:name
Delete a package
```json
{
  "success": true,
  "message": "Package deleted"
}
```

#### GET /api/templates
List available templates
```json
[
  {
    "name": "Autopilot-PSADT-4x",
    "path": "C:\\...\\Templates\\Autopilot-PSADT-4x"
  }
]
```

---

## ⚙️ Configuration

### Settings File: Config/settings.json

```json
{
  "CompanyPrefix": "MSP",        // Default company prefix
  "DefaultArch": "x64",           // Default architecture
  "DefaultLang": "EN",            // Default language
  "IncludePSADT": true,           // Auto-download PSADT
  "AutoOpenBrowser": true         // Open browser on start
}
```

### Edit via Web GUI
1. Click **⚙️ Settings** button
2. Modify values
3. Click **💾 Save Settings**

---

## 📋 Package Creation Workflow

### 1. Fill Form
- **Vendor** (required): e.g., "Adobe"
- **App Name** (required): e.g., "Reader DC"
- **Version** (required): e.g., "24.1.0"
- **Company Prefix**: e.g., "ZSD", "ACME"
- **Architecture**: x64, x86, ARM64
- **Language**: EN, DE, FR, etc.
- **MSI/EXE Filename**: Installer file name
- **Processes to Close**: Comma-separated list
- **Include PSADT**: Auto-download toolkit

### 2. Create Package
Click **🎉 Create Package**

### 3. Package Created
```
Output/Adobe_ReaderDC_24.1.0_x64/
├── Invoke-AppDeployToolkit.ps1
├── Detect-ReaderDC.ps1
├── README.md
├── Files/
│   ├── README.md
│   └── Config/
└── PSAppDeployToolkit/  (if auto-downloaded)
```

### 4. Add Installer
```
Copy installer to: Output/{PackageName}/Files/
```

### 5. Test Locally
```powershell
cd Output\{PackageName}
.\Invoke-AppDeployToolkit.ps1 -DeployMode Silent
.\Detect-*.ps1
```

### 6. Create IntuneWin
```powershell
IntuneWinAppUtil.exe -c "." -s "Invoke-AppDeployToolkit.ps1" -o "../IntuneWin"
```

### 7. Upload to Intune
- **Install Command**:
  ```
  powershell.exe -ExecutionPolicy Bypass -File "Invoke-AppDeployToolkit.ps1" -DeploymentType "Install" -DeployMode "Silent"
  ```
- **Uninstall Command**:
  ```
  powershell.exe -ExecutionPolicy Bypass -File "Invoke-AppDeployToolkit.ps1" -DeploymentType "Uninstall" -DeployMode "Silent"
  ```
- **Detection**: Custom Script → Detect-*.ps1

---

## 🔧 Advanced Usage

### Custom Port
```powershell
.\Start-PackageFactory.ps1 -Port 9090
```

### Command Line Package Creation
```powershell
# Import the generator module
. .\Generator\New-AutopilotPackage.ps1

# Create package
New-AutopilotPackage `
    -AppName "7-Zip" `
    -AppVendor "Igor Pavlov" `
    -AppVersion "23.01" `
    -MsiFilename "7z2301-x64.msi" `
    -OutputPath ".\Output" `
    -IncludePSADT
```

### Batch Creation (PowerShell)
```powershell
$packages = @(
    @{ Name = "7-Zip"; Vendor = "Igor Pavlov"; Version = "23.01"; Msi = "7z.msi" },
    @{ Name = "Notepad++"; Vendor = "Don Ho"; Version = "8.5.8"; Exe = "npp.exe" }
)

foreach ($pkg in $packages) {
    Invoke-RestMethod -Uri "http://localhost:8080/api/create-package" `
        -Method POST -ContentType "application/json" `
        -Body ($pkg | ConvertTo-Json)
}
```

---

## 🛠️ Troubleshooting

### Server Won't Start

**Problem**: "Pode module not found" or "Failed to download Pode module"
```
Solution 1 (Recommended): Run Setup-PortableMode.bat
  - Downloads Pode to Modules/ folder for offline use

Solution 2: Manual install
  - Open PowerShell as Administrator
  - Run: Install-Module Pode -Scope CurrentUser -Force
  - Copy from: $env:USERPROFILE\Documents\PowerShell\Modules\Pode
  - To: PackageFactory_v2.0_Portable\Modules\Pode

Solution 3: Use Docker
  - Run: Start-Docker-Quick.bat (no module installation needed)
```

**Problem**: Port 8080 already in use
```
Solution: Use custom port: .\Start-PackageFactory.ps1 -Port 9090
```

### Docker Shows Old Version

**Problem**: "Docker still shows old version after updating code"
```
Solution: Rebuild Docker image
  1. Stop: docker-compose down
  2. Remove old image: docker rmi packagefactory-v2-portable
  3. Rebuild: docker-compose up --build

Or simply run: Docker-Rebuild.bat (does all steps automatically)
```

**Problem**: "Docker build fails" or "Container won't start"
```
Solution 1: Clean rebuild
  Run: Docker-Rebuild.bat

Solution 2: Complete Docker cleanup
  docker-compose down
  docker system prune -a
  docker-compose up --build
```

### Package Creation Fails

**Problem**: "Template not found"
```
Solution: Ensure Generator/Templates/Autopilot-PSADT-4x exists
```

**Problem**: "Package already exists"
```
Solution: Delete existing package via GUI or manually from Output/
```

### PSADT Auto-Download Fails

**Problem**: No internet connection
```
Solution:
1. Uncheck "Include PSADT" option
2. Manually download from GitHub
3. Extract to package PSAppDeployToolkit/ folder
```

---

## 📚 Technical Details

### Requirements
- **Windows**: Windows 10/11 or Windows Server 2016+
- **PowerShell**: 5.1 or higher (PowerShell 7+ recommended)
- **Internet**: Required for first-time Pode download & PSADT auto-download

### Dependencies
- **Pode**: v2.x (auto-downloaded on first run)
- **PSAppDeployToolkit**: 4.1.5 (optional auto-download)

### Browser Support
- ✅ Chrome/Edge (Chromium)
- ✅ Firefox
- ✅ Safari
- ✅ Opera

### Security
- **Localhost Only**: Server binds to localhost (127.0.0.1)
- **No Authentication**: Designed for local use only
- **No Data Collection**: Everything stays on your machine

---

## 🔄 Upgrading from v1.3.0

### What Changed?
- ✅ **New**: Web GUI (v1.3.0 was CLI only)
- ✅ **New**: REST API for automation
- ✅ **New**: Package management UI
- ✅ **New**: Persistent settings
- ✅ **Same**: Template system (fully compatible)
- ✅ **Same**: Package output format
- ✅ **Same**: Registry detection pattern

### Migration Steps
1. **Copy Templates**:
   ```
   v1.3.0/Templates → v2.0/Generator/Templates
   ```
2. **Copy Packages**:
   ```
   v1.3.0/Output → v2.0/Output
   ```
3. **Start v2.0**:
   ```
   Double-click Start-PackageFactory.bat
   ```

---

## 🎓 Best Practices

### ✅ DO's
- ✅ Use consistent naming (Vendor_AppName_Version_Arch)
- ✅ Test packages locally before Intune upload
- ✅ Document installer requirements in Files/README.md
- ✅ Use company prefix for multi-tenant environments
- ✅ Keep template customizations in separate folder

### ❌ DON'Ts
- ❌ Don't expose server to network (security risk)
- ❌ Don't modify core templates (create copies instead)
- ❌ Don't forget to add installer files
- ❌ Don't skip detection script testing
- ❌ Don't use special characters in app names

---

## 📞 Support

**Christoph Ramböck**
Ramböck IT - Professional MSP Solutions

- **Email**: c@ramboeck.it
- **Website**: https://ramboeck.it

---

## 📋 Version History

| Version | Date | Changes |
|---------|------|---------|
| **2.0.1** | 2025-10-30 | 🐛 **Production Ready**<br>- Fixed Write-CMLog null path error<br>- Added Setup-PortableMode script<br>- Improved Pode installation handling<br>- Enhanced error messages<br>- Package Details modal with copy-to-clipboard<br>- 100% production ready |
| **2.0.0** | 2025-10-29 | 🎉 **Portable Web-GUI Release**<br>- Web-based interface<br>- REST API<br>- Package manager<br>- Settings UI<br>- Pode server integration |
| 1.3.0 | 2025-10-29 | - PSADT auto-download<br>- Multi-tenant support<br>- Centralized registry |
| 1.2.0 | 2025-10-29 | - Company prefix support |
| 1.0.0 | 2025-10-29 | - Initial release |

---

## 📜 License

**MIT License**

Copyright (c) 2025 Christoph Ramböck

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software.

---

## 🙏 Credits

- **PSAppDeployToolkit**: https://github.com/PSAppDeployToolkit/PSAppDeployToolkit
- **Pode Web Server**: https://github.com/Badgerati/Pode
- **Microsoft Intune**: https://docs.microsoft.com/intune

---

## 🎉 Ready to Go!

```
1. Extract Package Factory v2.0
2. Double-click Start-PackageFactory.bat
3. Browser opens automatically
4. Create your first package!
```

**Simple. Portable. Powerful.**

---

**© 2025 Ramböck IT - Package Factory v2.0 Portable**

*Crafted with ❤️ for MSPs worldwide*
