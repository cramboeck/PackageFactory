# QUICKFIX: Pode Installation für PowerShell 7

## Problem
Start-PackageFactory.bat schlägt fehl mit:
```
[ERROR] Failed to download Pode module
Error: The 'Get-PSRepository' command was found in the module 'PowerShellGet', but the module could not be loaded.
```

## Ursache
PowerShell 7 hat manchmal veraltete oder fehlende PowerShellGet/PackageManagement Module.

---

## ✅ Lösung 1: Pode global installieren (EMPFOHLEN)

Das ist die **einfachste und schnellste** Lösung:

### Schritt 1: PowerShell 7 als Administrator öffnen
```powershell
# Im Startmenü: "PowerShell 7" rechtsklick → Als Administrator ausführen
```

### Schritt 2: Pode installieren
```powershell
Install-Module Pode -Force
```

### Schritt 3: PackageFactory starten
```powershell
# Einfach Start-PackageFactory.bat doppelklicken
# ODER in PowerShell:
.\Start-PackageFactory.bat
```

**Fertig!** PackageFactory findet jetzt das global installierte Pode-Modul.

---

## ✅ Lösung 2: Manueller Download (ohne Admin-Rechte)

Falls du keine Admin-Rechte hast:

### Schritt 1: Pode von PowerShell Gallery herunterladen
1. Gehe zu: https://www.powershellgallery.com/packages/Pode
2. Klicke auf **"Manual Download"**
3. Lade die `.nupkg` Datei herunter (z.B. `pode.2.11.0.nupkg`)

### Schritt 2: Entpacken
1. Benenne die Datei um: `pode.2.11.0.nupkg` → `pode.2.11.0.zip`
2. Entpacke die ZIP-Datei
3. Im entpackten Ordner findest du einen Ordner der etwa so aussieht: `pode` oder ähnlich

### Schritt 3: In Modules-Ordner kopieren
```powershell
# Im PackageFactory Ordner:
# 1. Erstelle Modules\Pode Ordner falls nicht vorhanden
New-Item -Path ".\Modules\Pode" -ItemType Directory -Force

# 2. Kopiere den Inhalt der entpackten Pode-Dateien nach Modules\Pode
# (alle .ps1, .psd1, .psm1 Dateien müssen direkt in Modules\Pode liegen)
```

### Schritt 4: Struktur prüfen
```
PackageFactory\
  └── Modules\
      └── Pode\
          ├── Pode.psd1     ← Diese Datei muss vorhanden sein!
          ├── Pode.psm1
          └── ... (weitere Dateien)
```

### Schritt 5: Testen
```powershell
.\Start-PackageFactory.bat
```

---

## ✅ Lösung 3: PowerShellGet aktualisieren

Falls Save-Module nicht funktioniert:

```powershell
# PowerShell 7 als Administrator öffnen

# NuGet Provider installieren
Install-PackageProvider -Name NuGet -Force

# PowerShellGet aktualisieren
Install-Module PowerShellGet -Force -AllowClobber

# PowerShell neu starten, dann:
Install-Module Pode -Force
```

---

## ✅ Lösung 4: Docker verwenden

Wenn gar nichts funktioniert und Docker installiert ist:

```bash
# Im PackageFactory Ordner:
.\Start-Docker-Quick.bat

# Browser öffnet sich automatisch auf http://localhost:8080
```

Docker braucht **keine** PowerShell-Module!

---

## Testen ob es funktioniert

```powershell
# PowerShell 7 öffnen
Import-Module Pode

# Wenn kein Fehler kommt → Pode ist installiert ✓
# Wenn Fehler → eine der Lösungen oben nochmal durchgehen
```

---

## Warum passiert das?

PowerShell 7 und Windows PowerShell 5.1 sind **getrennte** Umgebungen:

- **PowerShell 5.1** Module: `C:\Users\DEINNAME\Documents\WindowsPowerShell\Modules`
- **PowerShell 7** Module: `C:\Users\DEINNAME\Documents\PowerShell\Modules`

Wenn du Pode in PowerShell 5.1 installiert hast, findet PowerShell 7 es nicht!

---

## Empfohlene Dauerlösung

1. **Pode global in PowerShell 7 installieren:**
   ```powershell
   Install-Module Pode -Force -Scope CurrentUser
   ```

2. **PackageFactory immer mit PowerShell 7 starten:**
   ```powershell
   pwsh.exe .\Start-PackageFactory.ps1
   ```

   Oder `.bat` Datei ändern zu:
   ```bat
   @echo off
   pwsh.exe -ExecutionPolicy Bypass -File "%~dp0Start-PackageFactory.ps1"
   ```

---

## Hilfe?

Falls nichts funktioniert, schick mir die Ausgabe von:

```powershell
# In PowerShell 7:
$PSVersionTable
Get-Module -ListAvailable Pode
$env:PSModulePath -split ';'
```
