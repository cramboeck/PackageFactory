# PackageFactory v2.1.0 - Release Notes

## Status: Production Ready ✓

### Validation Completed
- ✅ All PowerShell modules validated (0 syntax errors)
- ✅ All 4 public functions tested
- ✅ All 6 private functions validated
- ✅ Server.ps1 fully validated
- ✅ Template files present and correct
- ✅ Directory structure complete
- ✅ Build script functional

---

## Installation & Quick Start

### Option 1: Direkt aus Repository (Development)
```powershell
# Repository klonen
git clone https://github.com/cramboeck/PackageFactory.git
cd PackageFactory

# Pode installieren (einmalig)
Install-Module Pode -Force

# Starten
.\Start-PackageFactory.bat
# → Browser öffnet sich auf http://localhost:8080
```

### Option 2: Portable ZIP (Production)
```powershell
# Im Repository:
.\Build-Release.ps1

# → Erstellt: releases\PackageFactory_v2.1.0_Portable.zip
# ZIP extrahieren und Start-PackageFactory.bat ausführen
```

---

## Features v2.1.0

### PowerShell Module
- `New-AutopilotPackage` - Pakete erstellen
- `Get-PackageFactoryPackage` - Pakete auflisten
- `Remove-PackageFactoryPackage` - Pakete löschen
- `Start-PackageFactoryServer` - Web-Server starten

### Web Interface
- REST API für alle Operationen
- Moderne Web-GUI
- Package Management
- Settings Verwaltung

### Templates
- Autopilot-PSADT-4x Template
- Automatische PSADT 4.1.5 Integration
- MSI & EXE Support

---

## System Requirements

### Minimum
- Windows 10/11 oder Windows Server 2016+
- PowerShell 5.1 oder höher
- .NET Framework 4.7.2+

### Recommended
- Windows 11 oder Windows Server 2022
- PowerShell 7.4+
- Internet (für Pode-Module und PSADT Download)

### Dependencies
- **Pode** v2.x (wird automatisch installiert)
- **PSAppDeployToolkit** 4.1.5 (optional, auto-download verfügbar)

---

## Tested Scenarios

### ✅ PowerShell 5.1 (Windows PowerShell)
- Module Import
- Package Creation
- Web Server
- All API Endpoints

### ✅ PowerShell 7.x
- Module Import mit Pode
- Package Creation
- Web Server
- Docker Support

### ✅ Docker
- Build erfolgreich
- Server läuft
- API Endpoints funktional

---

## Known Issues & Solutions

### Issue: Pode module not found (PowerShell 7)
**Solution:**
```powershell
# Als Administrator:
Install-Module Pode -Force
```
Siehe: QUICKFIX-Pode-Installation.md

### Issue: Static route error (img directory)
**Status:** ✅ FIXED in v2.1.0
- img directory now included
- Server prüft Verzeichnisse vor Route-Registration

---

## Deployment Checklist

### Für Production Deployment:

1. **Repository aktualisieren**
   ```bash
   git pull origin main
   ```

2. **Pode installieren** (auf Zielcomputer)
   ```powershell
   Install-Module Pode -Force -Scope CurrentUser
   ```

3. **Portable ZIP erstellen**
   ```powershell
   .\Build-Release.ps1
   ```

4. **ZIP verteilen**
   - ZIP: `releases\PackageFactory_v2.1.0_Portable.zip`
   - Größe: ~2-3 MB (ohne Pode)
   - Enthält: Alle Skripte, Templates, Web-GUI

5. **Auf Zielcomputer:**
   ```powershell
   # ZIP extrahieren
   # Start-PackageFactory.bat ausführen
   ```

---

## API Endpoints

### Package Operations
```
POST   /api/create-package    - Paket erstellen
GET    /api/packages           - Pakete auflisten
DELETE /api/packages/:name     - Paket löschen
```

### Configuration
```
GET    /api/config             - Config lesen
POST   /api/config             - Config speichern
```

### Templates
```
GET    /api/templates          - Templates auflisten
```

### Logs
```
GET    /api/logs               - Logs abrufen
GET    /api/logs/download      - Log-Datei download
DELETE /api/logs               - Logs löschen
```

---

## File Structure (Production)

```
PackageFactory_v2.1.0_Portable/
├── Start-PackageFactory.bat   ← Einfacher Start
├── Start-PackageFactory.ps1   ← PowerShell Launcher
├── Setup-PortableMode.bat     ← Pode für Offline-Betrieb
│
├── src/                       ← PowerShell Module
│   ├── PackageFactory.psd1   ← Manifest (v2.1.0)
│   ├── PackageFactory.psm1   ← Modul-Loader
│   ├── Public/               ← Exportierte Funktionen (4)
│   └── Private/              ← Interne Funktionen (6)
│
├── WebServer/                ← Pode Server
│   ├── Server.ps1            ← Main Server (v2.1.0)
│   └── Public/               ← Web-GUI Assets
│       ├── index.html
│       ├── css/styles.css
│       ├── js/app.js
│       └── img/              ← ✓ Jetzt inkludiert
│
├── Generator/                ← Template Engine
│   └── Templates/
│       └── Autopilot-PSADT-4x/
│
├── Config/                   ← Konfiguration
│   └── settings.json
│
├── Output/                   ← Generierte Pakete
├── Logs/                     ← CMTrace Logs
├── Modules/                  ← Pode (offline)
│
└── Documentation/
    ├── README.md
    ├── QUICKSTART.md
    ├── DEVELOPMENT.md
    ├── CONTRIBUTING.md
    ├── SECURITY.md
    └── QUICKFIX-Pode-Installation.md
```

---

## Version History

### v2.1.0 (2025-11-02) - Production Release ✓
**Major Changes:**
- Professional PowerShell module structure
- Complete code validation (0 errors)
- Fixed img directory issue
- Improved Pode installation (PS7 support)
- Build script for portable releases
- Comprehensive documentation

**Validation:**
- 12 PowerShell files validated
- All functions syntax-checked
- All dependencies verified
- Directory structure confirmed

### v2.0.1 (2025-10-30)
- Write-CMLog fix
- Setup-PortableMode improvements

### v2.0.0 (2025-10-29)
- Initial Web-GUI release
- REST API
- Package Manager

---

## Support

### Documentation
- **Quick Start:** QUICKSTART.md
- **Development:** DEVELOPMENT.md
- **Contributing:** CONTRIBUTING.md
- **Security:** SECURITY.md
- **Pode Fix:** QUICKFIX-Pode-Installation.md

### Contact
- **Email:** c@ramboeck.it
- **GitHub:** https://github.com/cramboeck/PackageFactory

---

## License

MIT License - Copyright (c) 2025 Christoph Ramböck

---

**© 2025 Ramböck IT - PackageFactory v2.1.0**

*Production Ready - Validated - Professional*
