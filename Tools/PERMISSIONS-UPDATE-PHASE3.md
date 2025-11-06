# Phase 3 Permissions Update

## 🔴 Quick Fix für 400/403 Fehler

Du siehst aktuell diese Fehler:
- ❌ `400 Bad Request` beim Device Status
- ❌ `403 Forbidden` beim Erstellen von Groups

**Grund:** Neue Dashboard-Features brauchen zusätzliche Permissions!

---

## ✅ Lösung (5 Minuten)

### Schritt 1: Azure Portal öffnen
1. Gehe zu: https://portal.azure.com
2. Navigiere zu: **Azure Active Directory** → **App registrations**
3. Suche deine App: **PackageFactory-Intune** (oder wie du sie genannt hast)
4. Klicke drauf

### Schritt 2: Permissions hinzufügen

1. Linke Sidebar → **API permissions**
2. Klicke **+ Add a permission**
3. Wähle **Microsoft Graph**
4. Wähle **Application permissions** (nicht Delegated!)

**Füge diese 2 Permissions hinzu:**

#### Permission 1: Device Status lesen
- Suche: `DeviceManagementManagedDevices.Read.All`
- ✅ Checkbox aktivieren
- Klick **Add permissions**

#### Permission 2: Groups erstellen
- Klicke nochmal **+ Add a permission**
- Microsoft Graph → Application permissions
- **Falls du bereits `Group.Read.All` hast:**
  - Klicke die 3 Punkte (...) neben `Group.Read.All`
  - Wähle **Remove permission**
- Suche: `Group.ReadWrite.All` (mit Write!)
- ✅ Checkbox aktivieren
- Klick **Add permissions**

### Schritt 3: Admin Consent geben

**WICHTIG:** Ohne diesen Schritt funktioniert es NICHT!

1. Auf der **API permissions** Seite
2. Klicke den großen blauen Button: **✅ Grant admin consent for [Your Tenant]**
3. Bestätige mit **Yes**
4. Warte 2-3 Minuten (Permissions brauchen Zeit zum Propagieren)

### Schritt 4: Testen

1. Gehe zurück zu PackageFactory Dashboard
2. Drücke **F5** (Page Refresh)
3. Öffne eine App
4. Klicke **"Show Device Details"** → Sollte jetzt funktionieren ✅
5. Klicke **"Create Deployment Groups"** → Sollte jetzt funktionieren ✅

---

## 📋 Finale Permission Liste

Nach dem Update solltest du diese 4 Permissions haben:

| Permission | Type | Status | Reason |
|-----------|------|--------|--------|
| `DeviceManagementApps.ReadWrite.All` | Application | ✅ Required | Upload & manage apps |
| `DeviceManagementConfiguration.ReadWrite.All` | Application | ✅ Required | Configure app settings |
| `DeviceManagementManagedDevices.Read.All` | Application | ✅ Required | View device status |
| `Group.ReadWrite.All` | Application | ✅ Required | Create groups |

**Alle 4 müssen "Granted for [Tenant]" anzeigen!**

---

## 🐛 Immer noch Probleme?

### Permission wurde granted, aber 403 Fehler kommt immer noch:
- **Warte 5 Minuten** - Azure braucht Zeit zum Synchronisieren
- **Restart PowerShell** - Neue Tokens werden geholt
- **Clear Browser Cache** - Alte API responses können gecached sein

### "Grant admin consent" Button ist ausgegraut:
- Du brauchst **Global Administrator** oder **Application Administrator** Rolle
- Bitte einen Admin um Hilfe

### Andere Fehler:
- Siehe vollständige Troubleshooting-Anleitung: `Tools/INTUNE-SETUP.md`
- Checke ob Client Secret noch gültig ist (nicht expired)
- Test Connection in Settings durchführen

---

## 🎉 Fertig!

Nach dem Permission-Update hast du Zugriff auf:
- ✅ Advanced Filters (Publisher, Assignment Status)
- ✅ Detailed Device Status (wer hat die App installiert/failed)
- ✅ Auto-Create Deployment Groups (3 Groups per App)
- ✅ Assignment Management

**Viel Erfolg!** 🚀

---

**© 2025 Ramböck IT - PackageFactory**
