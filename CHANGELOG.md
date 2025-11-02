# 📋 Changelog - Package Factory

All notable changes to Package Factory will be documented in this file.

---

## [2.0.0] - 2025-10-29

### 🎉 Major Release - Portable Web-GUI Edition

#### Added
- ✨ **Web-Based GUI** - Modern, responsive browser interface
- ✨ **Pode Web Server** - Embedded, portable web server
- ✨ **REST API** - Full API for package creation and management
- ✨ **Package Manager UI** - View, manage, and delete packages via GUI
- ✨ **Settings UI** - Configure defaults via web interface
- ✨ **Portable Design** - Zero installation, runs from USB/Network
- ✨ **Auto Browser Launch** - Opens browser automatically on start
- ✨ **Batch Launcher** - Simple .bat file to start everything
- ✨ **API Documentation** - Complete API reference in README
- ✨ **Quick Start Guide** - QUICKSTART.md for rapid onboarding

#### Changed
- 🔄 **Architecture** - Migrated from CLI to Web-based architecture
- 🔄 **User Experience** - Form-based instead of command-line parameters
- 🔄 **Configuration** - JSON-based persistent settings
- 🔄 **Output** - Enhanced result display with next steps

#### Technical
- 📦 Server: Pode 2.x (PowerShell web framework)
- 🎨 Frontend: Vanilla JavaScript, modern CSS3
- 🔌 API: RESTful JSON endpoints
- 💾 Storage: File-based (JSON config, directory-based packages)

---

## [1.3.0] - 2025-10-29

### Added
- ✨ **Auto PSADT Download** - New `-IncludePSADT` parameter
- ✨ **GitHub Integration** - Automatically downloads PSADT 4.1.5
- ✨ **Smart Extraction** - Finds and copies PSAppDeployToolkit folder

#### Changed
- 🔄 Updated README with new parameter documentation
- 🔄 Enhanced user feedback during PSADT download
- 🔄 Improved error handling for download failures

---

## [1.2.0] - 2025-10-29

### Added
- ✨ **Multi-Tenant Support** - New `-CompanyPrefix` parameter
- ✨ **Centralized Registry** - `{PREFIX}_IntuneAppInstall\Apps\` pattern
- ✨ **Rich Metadata** - DisplayName, DisplayVersion, InstallDate, Publisher
- ✨ **MSP-Ready** - Perfect for managing multiple customers

#### Documentation
- 📚 CENTRALIZED_REGISTRY_PATTERN.md
- 📚 DETECTION_KEY_STANDARD.md
- 📚 Updated README with multi-tenant examples

---

## [1.1.0] - 2025-10-29

### Added
- ✨ **Enhanced Templates** - Improved PSADT 4.x syntax
- ✨ **Example Package** - FortiClient VPN reference implementation
- ✨ **Process Management** - Better handling of processes to close

#### Fixed
- 🐛 Fixed template placeholder replacements
- 🐛 Improved error messages

---

## [1.0.0] - 2025-10-29

### Initial Release

#### Features
- ✨ **Template-Based Generation** - Autopilot-PSADT-4x template
- ✨ **CLI Generator** - `New-AutopilotPackage.ps1` script
- ✨ **MSI/EXE Support** - Flexible installer types
- ✨ **Detection Script** - Registry-based detection
- ✨ **README Generation** - Automatic documentation
- ✨ **PSADT 4.x Compatible** - Latest toolkit syntax

#### Templates
- 📦 Autopilot-PSADT-4x
  - Invoke-AppDeployToolkit.ps1.template
  - Detect-Application.ps1.template

#### Documentation
- 📚 README.md
- 📚 QUICK_REFERENCE.md

---

## Version Comparison

| Feature | v1.0 | v1.2 | v1.3 | v2.0 |
|---------|------|------|------|------|
| CLI Generator | ✅ | ✅ | ✅ | ✅ |
| Web GUI | ❌ | ❌ | ❌ | ✅ |
| Company Prefix | ❌ | ✅ | ✅ | ✅ |
| Auto PSADT | ❌ | ❌ | ✅ | ✅ |
| REST API | ❌ | ❌ | ❌ | ✅ |
| Package Manager | ❌ | ❌ | ❌ | ✅ |
| Settings UI | ❌ | ❌ | ❌ | ✅ |
| Portable | ❌ | ❌ | ❌ | ✅ |

---

## Roadmap

### Future Considerations (v2.1+)

#### Planned Features
- 🔮 **IntuneWin Creator** - Built-in .intunewin creation
- 🔮 **Intune Upload** - Direct upload via Graph API
- 🔮 **Template Manager** - Add/edit templates via GUI
- 🔮 **Batch Import** - CSV-based bulk creation
- 🔮 **Package Validation** - Pre-flight checks and testing
- 🔮 **Version Management** - Update existing packages
- 🔮 **Export/Import** - Package configuration exchange
- 🔮 **Multi-Language** - GUI localization

#### Under Consideration
- 💭 Dark mode theme
- 💭 Package comparison tool
- 💭 Deployment statistics
- 💭 Integration with RMM tools
- 💭 Custom template wizard
- 💭 Package catalog/library

---

## Migration Guides

### Upgrading from v1.x to v2.0

**What's Preserved:**
- ✅ All templates (100% compatible)
- ✅ Package structure
- ✅ Detection scripts
- ✅ Registry patterns

**What's New:**
- 🆕 Web GUI (optional, CLI still works)
- 🆕 API endpoints (for automation)
- 🆕 Settings management

**Migration Steps:**
1. Extract v2.0 to new folder
2. Copy templates: `v1.x/Templates → v2.0/Generator/Templates`
3. Copy packages: `v1.x/Output → v2.0/Output`
4. Launch: `Start-PackageFactory.bat`

**Backward Compatibility:**
- ✅ v1.x templates work in v2.0
- ✅ v1.x packages can be managed in v2.0 GUI
- ✅ CLI generator still available for scripting

---

## Support

**Report Issues:**
- Email: c@ramboeck.it
- Include version number and error details

**Feature Requests:**
- Email suggestions to c@ramboeck.it
- Check roadmap first to avoid duplicates

---

**© 2025 Ramböck IT - Package Factory**
