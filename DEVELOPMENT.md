# PackageFactory - Development & Testing Guide

## Lokale Entwicklung und Testing

### Option 1: Mit GitHub Desktop

#### Einmaliges Setup
1. **Repository klonen**
   - GitHub Desktop öffnen
   - `File` → `Clone Repository`
   - Wähle `cramboeck/PackageFactory`
   - Lokalen Pfad auswählen (z.B. `C:\Dev\PackageFactory`)
   - `Clone` klicken

#### Neueste Version abholen
1. GitHub Desktop öffnen
2. Repository `PackageFactory` auswählen
3. Oben auf `Fetch origin` klicken
4. Wenn Updates verfügbar: `Pull origin` klicken

#### Testen der neuesten Version
```powershell
# PowerShell im Repository-Ordner öffnen
cd C:\Dev\PackageFactory

# Modul importieren
Import-Module .\src\PackageFactory.psd1 -Force

# Webserver starten
.\Start-PackageFactory.bat

# ODER: Cmdlets direkt nutzen
New-AutopilotPackage -AppName "TestApp" -AppVendor "TestVendor" -AppVersion "1.0.0"
```

### Option 2: Mit Git CLI

#### Einmaliges Setup
```bash
# Repository klonen
git clone https://github.com/cramboeck/PackageFactory.git
cd PackageFactory
```

#### Neueste Version abholen
```bash
# In das Repository-Verzeichnis wechseln
cd PackageFactory

# Neueste Änderungen vom main Branch holen
git checkout main
git pull origin main

# ODER: Neueste Änderungen vom dev Branch holen
git checkout dev
git pull origin dev

# ODER: Einen bestimmten Branch testen
git fetch origin
git checkout feature/neue-funktion
git pull origin feature/neue-funktion
```

#### Zwischen Branches wechseln
```bash
# Alle verfügbaren Branches anzeigen
git branch -a

# Zu einem Branch wechseln
git checkout main          # Production
git checkout dev           # Development
git checkout feature/xyz   # Feature Branch
```

### Option 3: Portable ZIP erstellen und testen

#### ZIP-Datei aus aktuellem Stand erstellen
```powershell
# Im Repository-Ordner
.\Build-Release.ps1

# ZIP-Datei wird erstellt in: .\releases\PackageFactory_vX.X.X_Portable.zip
```

#### ZIP testen
1. ZIP-Datei aus `releases\` Ordner extrahieren
2. In extrahierten Ordner wechseln
3. `Start-PackageFactory.bat` doppelklicken
4. Browser öffnet sich automatisch

### Testing-Workflow nach jedem Commit

#### Schnelltest (Empfohlen)
```powershell
# 1. Neueste Version holen (siehe oben)

# 2. Modul neu laden
Import-Module .\src\PackageFactory.psd1 -Force

# 3. Basis-Funktionen testen
Get-Command -Module PackageFactory

# 4. Testpaket erstellen
New-AutopilotPackage `
    -AppName "TestApp" `
    -AppVendor "TestVendor" `
    -AppVersion "1.0.0" `
    -MsiFilename "test.msi"

# 5. Paket prüfen
Get-PackageFactoryPackage

# 6. Webserver testen
.\Start-PackageFactory.bat
# Browser: http://localhost:8080
```

#### Vollständiger Test
```powershell
# 1. Neueste Version holen

# 2. Portable ZIP erstellen
.\Build-Release.ps1

# 3. ZIP extrahieren in Testordner
$testPath = "C:\Temp\PackageFactory_Test"
Expand-Archive -Path ".\releases\PackageFactory_*.zip" -DestinationPath $testPath -Force

# 4. In Testordner wechseln und testen
cd $testPath\PackageFactory_*
.\Start-PackageFactory.bat

# 5. Verschiedene Szenarien testen:
#    - Paket mit MSI erstellen
#    - Paket mit EXE erstellen
#    - PSADT Download testen
#    - Settings speichern
#    - Pakete löschen
```

## Entwicklungs-Branches

### main
- **Zweck**: Produktions-Code
- **Stabilität**: Stabil, getestet
- **Wann nutzen**: Für produktive Verwendung

### dev
- **Zweck**: Development-Code
- **Stabilität**: Kann instabil sein
- **Wann nutzen**: Neueste Features testen

### feature/* Branches
- **Zweck**: Neue Features in Entwicklung
- **Stabilität**: Experimentell
- **Wann nutzen**: Spezifische neue Features testen

## Quick Reference

### GitHub Desktop Workflow
```
1. Fetch origin (Änderungen prüfen)
2. Pull origin (Änderungen holen)
3. Testen
4. Feedback geben
```

### Git CLI Workflow
```bash
git pull origin main              # Neueste Version holen
Import-Module .\src\*.psd1 -Force # Modul laden
.\Build-Release.ps1               # ZIP erstellen (optional)
```

### Portable ZIP Workflow
```powershell
.\Build-Release.ps1                          # ZIP erstellen
Expand-Archive .\releases\*.zip -Dest C:\Test # Extrahieren
C:\Test\PackageFactory_*\Start-*.bat         # Testen
```

## Troubleshooting

### "Modul konnte nicht geladen werden"
```powershell
# PowerShell Execution Policy prüfen
Get-ExecutionPolicy

# Falls "Restricted", ändern zu:
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### "Pode module not found"
```powershell
# Setup-Script ausführen (einmalig mit Internet)
.\Setup-PortableMode.bat

# ODER: Pode manuell installieren
Install-Module Pode -Scope CurrentUser
```

### Änderungen werden nicht übernommen
```powershell
# Modul vollständig entladen und neu laden
Remove-Module PackageFactory -Force -ErrorAction SilentlyContinue
Import-Module .\src\PackageFactory.psd1 -Force
```

## Build für GitHub Release

### Manueller Release-Prozess
```powershell
# 1. Version in Manifest prüfen/anpassen
notepad .\src\PackageFactory.psd1
# ModuleVersion = '2.1.0'

# 2. CHANGELOG.md aktualisieren
notepad .\CHANGELOG.md

# 3. Änderungen committen
git add -A
git commit -m "chore: Prepare release v2.1.0"
git push

# 4. ZIP erstellen
.\Build-Release.ps1

# 5. GitHub Release erstellen
#    - Gehe zu: https://github.com/cramboeck/PackageFactory/releases/new
#    - Tag: v2.1.0
#    - Release title: PackageFactory v2.1.0
#    - ZIP hochladen aus: .\releases\
```

## Feedback & Issues

Bei Problemen oder Feedback:
- GitHub Issues: https://github.com/cramboeck/PackageFactory/issues
- Email: c@ramboeck.it

## Nützliche Befehle

```powershell
# Alle verfügbaren Cmdlets anzeigen
Get-Command -Module PackageFactory

# Hilfe zu einem Cmdlet
Get-Help New-AutopilotPackage -Full

# Modul-Version prüfen
(Get-Module PackageFactory).Version

# Aktuellen Git-Branch anzeigen
git branch --show-current

# Letzte Commits anzeigen
git log --oneline -10

# Alle Remote-Branches anzeigen
git branch -r
```
