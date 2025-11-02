# ⚡ Quick Start Guide - Package Factory v2.0

## 🚀 Get Started in 60 Seconds

### Step 1: Launch (10 seconds)
```
Double-click: Start-PackageFactory.bat
```
- Server starts automatically
- Browser opens to http://localhost:8080
- Ready to create packages!

---

### Step 2: Fill Form (30 seconds)
```
Required Fields:
✅ Vendor: "Adobe"
✅ App Name: "Reader DC"
✅ Version: "24.1.0"

Optional:
- Company Prefix: "ZSD" (for MSPs)
- MSI Filename: "AcroRead.msi"
- Processes: "AcroRd32"
☑️ Include PSADT: Checked
```

---

### Step 3: Create Package (20 seconds)
```
Click: 🎉 Create Package

✅ Success!
Package: Adobe_ReaderDC_24.1.0_x64
Location: Output\Adobe_ReaderDC_24.1.0_x64
```

---

## 📁 Next Steps

### Add Installer
```
1. Navigate to: Output\Adobe_ReaderDC_24.1.0_x64\Files\
2. Copy your installer: AcroRead.msi
```

### Test Package
```powershell
cd Output\Adobe_ReaderDC_24.1.0_x64
.\Invoke-AppDeployToolkit.ps1 -DeployMode Silent
.\Detect-ReaderDC.ps1
```

### Create IntuneWin
```powershell
IntuneWinAppUtil.exe -c "." -s "Invoke-AppDeployToolkit.ps1" -o "Output"
```

---

## 🎯 Common Scenarios

### Scenario 1: MSI Application
```
Vendor: "Microsoft"
Name: "Teams"
Version: "1.6.00"
MSI Filename: "Teams.msi"
Processes: "Teams"
```

### Scenario 2: EXE Application
```
Vendor: "Mozilla"
Name: "Firefox"
Version: "120.0"
EXE Filename: "Firefox_Setup.exe"
Processes: "firefox"
```

### Scenario 3: Multi-Tenant MSP
```
Vendor: "7-Zip"
Name: "7-Zip"
Version: "23.01"
Company Prefix: "ACME"  ← Customer identifier
MSI Filename: "7z2301-x64.msi"
```

---

## ⚙️ Quick Settings

Click **⚙️ Settings** to set defaults:

```
Default Company Prefix: "MSP" or "YourMSP"
Default Architecture: "x64"
Default Language: "EN"
Auto-include PSADT: ☑️ Checked
```

**Saves time on every package!**

---

## 📋 View Packages

Click **📋 Packages** to:
- View all created packages
- See creation dates
- Delete old packages

---

## 💡 Pro Tips

### 1. Use Templates
```
All packages follow the same proven template
→ Consistent, tested, production-ready
```

### 2. Test First
```
ALWAYS test locally before uploading to Intune
→ Saves time, prevents failed deployments
```

### 3. Company Prefix
```
Use customer codes for MSPs
→ ZSD_IntuneAppInstall\Apps\...
→ ACME_IntuneAppInstall\Apps\...
```

### 4. Batch Creation
```
Create multiple packages in a row
→ Form remembers your settings
→ Quick and efficient
```

---

## 🛠️ Troubleshooting

### Server Won't Start?
```
1. Check PowerShell version: $PSVersionTable.PSVersion
2. Ensure port 8080 is free
3. Try custom port: .\Start-PackageFactory.ps1 -Port 9090
```

### Browser Doesn't Open?
```
Manually open: http://localhost:8080
```

### Package Creation Fails?
```
1. Check all required fields are filled
2. Ensure Output folder is writable
3. Check package doesn't already exist
```

---

## 🎓 Learn More

- **Full README**: README.md
- **Template Documentation**: Generator/Templates/
- **PSADT Docs**: https://github.com/PSAppDeployToolkit/PSAppDeployToolkit

---

## 📞 Need Help?

**Christoph Ramböck**
- Email: c@ramboeck.it
- Web: https://ramboeck.it

---

**Ready? Let's create some packages! 🚀**
