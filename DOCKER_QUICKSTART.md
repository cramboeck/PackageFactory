# 🚀 Docker Quick Start - PackageFactory v2.0

## TL;DR - Schnellster Start

### Windows

**Einfach doppelklicken:**
```
Start-Docker-Quick.bat
```

**Oder mit PowerShell:**
```powershell
.\Start-Docker-Quick.ps1
```

**Das war's! Browser öffnet automatisch.** 🎉

---

## 🎯 Was macht das Quick-Start-Script?

Das Script macht **ALLES automatisch**:

1. ✅ Prüft ob Docker installiert ist
2. ✅ Prüft ob Docker läuft
3. ✅ Stoppt alte Container
4. ✅ Prüft ob Port frei ist
5. ✅ Startet Container neu
6. ✅ Wartet bis Server bereit ist
7. ✅ Öffnet Browser automatisch

**Kein manuelles Troubleshooting mehr!**

---

## 📋 Verfügbare Scripts

### 1. Start-Docker-Quick.bat (Empfohlen!)
**Einfachste Methode** - Funktioniert immer
```
Doppelklick auf Start-Docker-Quick.bat
```

### 2. Start-Docker-Quick.ps1 (PowerShell)
**Mit erweiterten Optionen**

```powershell
# Normal starten
.\Start-Docker-Quick.ps1

# Mit anderem Port
.\Start-Docker-Quick.ps1 -Port 9090

# Mit kompletter Neuinstallation (löscht alte Container/Images)
.\Start-Docker-Quick.ps1 -Clean
```

### 3. Start-Docker.bat (Original)
**Basis-Version** - Weniger Automatisierung
```
Doppelklick auf Start-Docker.bat
```

---

## 🔧 Parameter (nur PowerShell)

### -Port
Verwendet anderen Port falls 8080 belegt ist
```powershell
.\Start-Docker-Quick.ps1 -Port 9090
```
Dann: `http://localhost:9090`

### -Clean
Löscht alte Container und Images komplett
```powershell
.\Start-Docker-Quick.ps1 -Clean
```
Nützlich bei:
- Problemen mit alten Containern
- Nach Updates
- Bei merkwürdigem Verhalten

---

## ❌ Fehlerbehandlung

Das Script erkennt und behebt automatisch:

### Problem: Docker nicht installiert
```
✗ Docker not found!

Lösung: https://www.docker.com/products/docker-desktop
```

### Problem: Docker läuft nicht
```
✗ Docker daemon not running!

Lösung: Docker Desktop starten
```

### Problem: Port 8080 belegt
```
✗ Port 8080 is in use!

Process using port 8080:
  Id   ProcessName  Path
  1234 java.exe     C:\Program Files\Java\...

Options:
  1. Kill the process: taskkill /PID 1234 /F
  2. Use different port: .\Start-Docker-Quick.ps1 -Port 9090

Try different port 9090? (y/n)
```
**Script bietet automatisch Port 9090 an!**

### Problem: Server startet nicht
```
✗ Server did not respond in time

Showing logs:
[Letzte 50 Zeilen der Container-Logs]
```

---

## 🎬 Beispiel-Ablauf

```
========================================
  PackageFactory v2.0 - Docker Setup
========================================

[INFO] Working directory: C:\temp\PackageFactory_v2.0_Portable

[1/6] Checking Docker...
  ✓ Docker found

[2/6] Checking Docker daemon...
  ✓ Docker daemon is running

[3/6] Checking configuration...
  ✓ docker-compose.yml found

[4/6] Stopping existing containers...
  ✓ Stopped

[5/6] Checking port 8080...
  ✓ Port 8080 is available

[6/6] Starting PackageFactory container...
  Starting services...
  ✓ Container started successfully!

Waiting for server to start...
  ✓ Server is ready!

========================================
  PackageFactory v2.0 Started!
========================================

  Web-GUI: http://localhost:8080

Useful Commands:
  docker-compose logs -f       View logs
  docker-compose down          Stop container
  docker-compose restart       Restart container

Opening browser...
```

---

## 💡 Tipps & Tricks

### Container läuft, aber Browser zeigt nichts?
```powershell
# Script neu starten mit Clean-Option
.\Start-Docker-Quick.ps1 -Clean
```

### Port-Konflikt beheben?
```powershell
# Automatisch anderen Port verwenden
.\Start-Docker-Quick.ps1 -Port 9090
```

### Logs live anschauen?
```bash
docker-compose logs -f
```

### Container komplett neu bauen?
```powershell
.\Start-Docker-Quick.ps1 -Clean
```

### Manuell testen ob Server läuft?
```powershell
Invoke-WebRequest http://localhost:8080 -UseBasicParsing
```

---

## 🔄 Unterschied zu anderen Start-Methoden

| Methode | Automatisch | Fehlerbehandlung | Port-Check | Wartet auf Server |
|---------|-------------|------------------|------------|-------------------|
| **Start-Docker-Quick.bat** | ✅ | ✅ | ❌ | ✅ |
| **Start-Docker-Quick.ps1** | ✅ | ✅ | ✅ | ✅ |
| Start-Docker.bat | ✅ | ⚠️ Basis | ❌ | ⚠️ Kurz |
| `docker-compose up -d` | ❌ | ❌ | ❌ | ❌ |

**→ Start-Docker-Quick.ps1 ist die beste Wahl!**

---

## 🆘 Wenn gar nichts funktioniert

### Kompletter Reset
```powershell
# 1. Script mit Clean ausführen
.\Start-Docker-Quick.ps1 -Clean

# 2. Falls das nicht hilft - WSL neu starten (Windows)
wsl --shutdown

# 3. Docker Desktop neu starten

# 4. Script nochmal ausführen
.\Start-Docker-Quick.ps1 -Clean
```

### Manuelle Diagnose
```powershell
# Docker Version
docker --version

# Läuft Docker?
docker ps

# Container Status
docker-compose ps

# Logs anschauen
docker-compose logs --tail 100

# Port-Check
Test-NetConnection -ComputerName localhost -Port 8080
```

---

## 📞 Support

**Bei Problemen mit dem Quick-Start-Script:**

1. **Logs sammeln:**
   ```powershell
   docker-compose logs > logs.txt
   ```

2. **System-Info:**
   ```powershell
   docker --version
   docker-compose --version
   ```

3. **Email an:** c@ramboeck.it

---

## ✨ Features der Quick-Start-Scripts

### Automatische Fehlerbehandlung
- ✅ Docker-Installation prüfen
- ✅ Docker-Daemon prüfen
- ✅ Port-Verfügbarkeit prüfen
- ✅ Alte Container aufräumen
- ✅ Server-Readiness warten
- ✅ Browser automatisch öffnen

### Intelligente Port-Auswahl
- ✅ Erkennt belegte Ports
- ✅ Zeigt blockierenden Prozess
- ✅ Bietet Alternative an
- ✅ Updated Konfiguration automatisch

### Container-Management
- ✅ Stoppt alte Container
- ✅ Optional: Löscht alte Images
- ✅ Baut neu bei Bedarf
- ✅ Wartet auf Server-Start

---

## 🎓 Best Practices

### Regelmäßige Nutzung
```powershell
# Normal starten
.\Start-Docker-Quick.ps1
```

### Nach Updates
```powershell
# Mit Clean-Option
.\Start-Docker-Quick.ps1 -Clean
```

### Bei Port-Konflikten
```powershell
# Anderen Port verwenden
.\Start-Docker-Quick.ps1 -Port 9090
```

### Entwicklung/Testing
```bash
# Logs live verfolgen
docker-compose logs -f
```

---

**Quick-Start macht PackageFactory v2.0 noch einfacher! 🚀**

*Keine Kommandozeilen-Kenntnisse mehr erforderlich - einfach doppelklicken!*

---

**© 2025 Ramböck IT - PackageFactory v2.0**
