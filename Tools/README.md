# Tools Directory

This directory contains external tools used by PackageFactory.

## IntuneWinAppUtil.exe

**Purpose:** Creates .intunewin packages for Microsoft Intune deployment.

### Download Instructions

1. Download from Microsoft: https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool
2. Extract `IntuneWinAppUtil.exe` from the release archive
3. Place the file in this directory: `Tools/IntuneWinAppUtil.exe`

### File Location

```
PackageFactory/
└── Tools/
    └── IntuneWinAppUtil.exe  ← Place file here
```

### Verification

Once placed, PackageFactory will automatically detect the tool and enable IntuneWin package creation from the web interface.

**Note:** This file is not included in the repository due to Microsoft licensing. You must download it separately.

---

**© 2025 Ramböck IT**
