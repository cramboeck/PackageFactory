# 📂 Package Factory v2.0 - File Structure

## Directory Overview

```
PackageFactory_v2.0_Portable/
│
├── 🚀 Start-PackageFactory.bat          Launch file (Windows)
├── 🚀 Start-PackageFactory.ps1          PowerShell launcher
├── 📄 Create-IntuneWin.ps1              IntuneWin creation helper
│
├── 📚 README.md                         Main documentation
├── 📚 QUICKSTART.md                     Quick start guide
├── 📚 CHANGELOG.md                      Version history
├── 📚 STRUCTURE.md                      This file
│
├── 📁 Config/                           Configuration files
│   └── settings.json                    User settings (persistent)
│
├── 📁 WebServer/                        Web server & API
│   ├── Server.ps1                       Pode server + REST API
│   └── Public/                          Static web files
│       ├── index.html                   Main web interface
│       ├── css/
│       │   └── styles.css               Styling
│       ├── js/
│       │   └── app.js                   Frontend logic
│       └── img/                         Images (future use)
│
├── 📁 Generator/                        Package generator
│   └── Templates/                       Package templates
│       └── Autopilot-PSADT-4x/          Default template
│           ├── Invoke-AppDeployToolkit.ps1.template
│           └── Detect-Application.ps1.template
│
├── 📁 Modules/                          PowerShell modules
│   ├── .gitkeep                         (keeps directory in git)
│   └── Pode/                            (auto-downloaded on first run)
│
├── 📁 Output/                           Generated packages
│   ├── .gitkeep                         (keeps directory in git)
│   └── {PackageName}/                   (created packages appear here)
│       ├── Invoke-AppDeployToolkit.ps1
│       ├── Detect-*.ps1
│       ├── README.md
│       ├── Files/
│       │   ├── README.md
│       │   └── Config/
│       └── PSAppDeployToolkit/          (if auto-downloaded)
│
└── 📁 Tools/                            (created on first IntuneWin creation)
    └── IntuneWinAppUtil.exe             (auto-downloaded)
```

---

## File Descriptions

### Launch Files

**Start-PackageFactory.bat**
- Windows batch file launcher
- Checks for PowerShell
- Starts the PowerShell launcher
- **Usage**: Double-click to start

**Start-PackageFactory.ps1**
- PowerShell launcher script
- Downloads Pode module if missing
- Imports Pode
- Starts web server
- Opens browser automatically
- **Usage**: `.\Start-PackageFactory.ps1 [-Port 8080]`

---

### Web Server

**WebServer/Server.ps1**
- Main Pode web server
- REST API endpoints
- Package generation logic
- Configuration management
- **Runs on**: http://localhost:8080 (default)

**WebServer/Public/index.html**
- Main web interface
- Package creation form
- Settings modal
- Packages modal
- Responsive design

**WebServer/Public/css/styles.css**
- Modern CSS3 styling
- Gradient themes
- Responsive layout
- Animation effects

**WebServer/Public/js/app.js**
- Frontend JavaScript
- API communication
- Form handling
- Modal management

---

### Configuration

**Config/settings.json**
- Persistent user settings
- Default values for forms
- Company prefix
- Architecture & language defaults
- PSADT auto-download preference

```json
{
  "CompanyPrefix": "MSP",
  "DefaultArch": "x64",
  "DefaultLang": "EN",
  "IncludePSADT": true,
  "AutoOpenBrowser": true
}
```

---

### Generator

**Generator/Templates/Autopilot-PSADT-4x/**

Template directory containing:

**Invoke-AppDeployToolkit.ps1.template**
- Deployment script template
- Placeholders: `{{APP_NAME}}`, `{{APP_VENDOR}}`, etc.
- PSADT 4.x syntax
- Install/Uninstall logic

**Detect-Application.ps1.template**
- Detection script template
- Registry-based detection
- Centralized pattern: `{PREFIX}_IntuneAppInstall\Apps\`
- Version verification

---

### Utilities

**Create-IntuneWin.ps1**
- Helper for .intunewin creation
- Auto-downloads IntuneWinAppUtil.exe
- Interactive package selection
- Provides Intune upload instructions

**Usage**:
```powershell
.\Create-IntuneWin.ps1
# or
.\Create-IntuneWin.ps1 -PackagePath ".\Output\Adobe_ReaderDC_24.1.0_x64"
```

---

### Documentation

**README.md**
- Complete documentation
- Features overview
- API reference
- Configuration guide
- Troubleshooting

**QUICKSTART.md**
- 60-second quick start
- Common scenarios
- Pro tips
- Quick troubleshooting

**CHANGELOG.md**
- Version history
- Feature additions
- Bug fixes
- Migration guides

**STRUCTURE.md**
- This file
- Directory structure
- File descriptions

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Main web interface |
| GET | `/api/config` | Get configuration |
| POST | `/api/config` | Save configuration |
| POST | `/api/create-package` | Create new package |
| GET | `/api/packages` | List all packages |
| DELETE | `/api/packages/:name` | Delete package |
| GET | `/api/templates` | List templates |

---

## Auto-Downloaded Components

### Pode Module
- **Location**: `Modules/Pode/`
- **Version**: Latest from PSGallery
- **Downloaded**: On first run (if missing)
- **Required**: Yes

### PSAppDeployToolkit
- **Location**: Inside each package `PSAppDeployToolkit/`
- **Version**: 4.1.5
- **Downloaded**: When "Include PSADT" is checked
- **Required**: No (can be added manually)

### IntuneWinAppUtil.exe
- **Location**: `Tools/IntuneWinAppUtil.exe`
- **Source**: Microsoft GitHub
- **Downloaded**: When running `Create-IntuneWin.ps1`
- **Required**: Only for .intunewin creation

---

## Generated Package Structure

When you create a package, the following structure is generated:

```
Output/{Vendor}_{AppName}_{Version}_{Arch}/
│
├── Invoke-AppDeployToolkit.ps1          Deployment script
├── Detect-{AppName}.ps1                 Detection script
├── README.md                            Package documentation
│
├── Files/                               Installation files
│   ├── README.md                        Instructions
│   └── Config/                          Config files (if needed)
│
└── PSAppDeployToolkit/                  (if auto-downloaded)
    ├── PSAppDeployToolkit.psd1
    ├── PSAppDeployToolkit.psm1
    └── [Additional PSADT files...]
```

---

## Customization

### Adding Templates

1. Create new template folder:
   ```
   Generator/Templates/My-Custom-Template/
   ```

2. Add template files:
   ```
   Invoke-AppDeployToolkit.ps1.template
   Detect-Application.ps1.template
   ```

3. Use placeholders:
   ```
   {{APP_NAME}}
   {{APP_VENDOR}}
   {{APP_VERSION}}
   {{COMPANY_PREFIX}}
   {{MSI_FILENAME}}
   etc.
   ```

### Modifying Web GUI

**HTML**: Edit `WebServer/Public/index.html`
**CSS**: Edit `WebServer/Public/css/styles.css`
**JavaScript**: Edit `WebServer/Public/js/app.js`

**Note**: Changes take effect after server restart

---

## Backup & Portability

### Essential Files (keep these)
- ✅ `Start-PackageFactory.bat`
- ✅ `Start-PackageFactory.ps1`
- ✅ `WebServer/` (entire folder)
- ✅ `Generator/Templates/` (entire folder)
- ✅ `Config/settings.json` (your settings)
- ✅ Documentation (*.md files)

### Auto-Regenerated (can be deleted)
- ❌ `Modules/Pode/` (re-downloaded automatically)
- ❌ `Output/*` (your packages - backup if needed!)
- ❌ `Tools/` (re-downloaded when needed)

### For Distribution
```
1. Delete: Modules/Pode/, Output/*, Tools/
2. Keep: Everything else
3. Zip entire folder
4. Distribute!
```

---

## File Sizes (Approximate)

| Component | Size |
|-----------|------|
| Web Server & GUI | ~100 KB |
| Templates | ~20 KB |
| Documentation | ~50 KB |
| **Total (without dependencies)** | **~200 KB** |
| Pode Module (downloaded) | ~2 MB |
| PSADT per package (downloaded) | ~500 KB |
| IntuneWinAppUtil (downloaded) | ~1 MB |

**Portable package is extremely lightweight!**

---

## Security Notes

### Local Only
- Server binds to `localhost` (127.0.0.1)
- Not accessible from network
- Safe for portable use

### No Authentication
- Designed for single-user local use
- Do not expose to network without authentication

### No Telemetry
- No data collection
- Everything stays local
- No external connections (except downloads)

---

## Development

### Technologies Used
- **Backend**: PowerShell + Pode Web Server
- **Frontend**: Vanilla JavaScript (no frameworks)
- **Styling**: Pure CSS3
- **API**: RESTful JSON
- **Storage**: File-based (JSON + directories)

### Adding Features

**New API Endpoint**:
Edit `WebServer/Server.ps1`, add route:
```powershell
Add-PodeRoute -Method Get -Path '/api/my-endpoint' -ScriptBlock {
    Write-PodeJsonResponse -Value @{ data = "value" }
}
```

**New GUI Feature**:
1. Edit HTML: `WebServer/Public/index.html`
2. Edit CSS: `WebServer/Public/css/styles.css`
3. Edit JS: `WebServer/Public/js/app.js`

---

**© 2025 Ramböck IT - Package Factory v2.0**
