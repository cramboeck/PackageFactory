# Intune Integration Setup Guide

This guide helps you configure PackageFactory for **complete automated integration** with Microsoft Intune.

## ✨ Features

✅ **Phase 2 - Complete Automation** (Current)
- ✅ Automatic .intunewin package creation
- ✅ Direct upload to Microsoft Intune (no manual steps!)
- ✅ Automatic app creation with full metadata
- ✅ Detection rules, install/uninstall commands configured
- ✅ Azure Storage chunked upload (supports large files)
- ✅ Content versioning and commit

**No PowerShell modules required** - uses Microsoft Graph API directly!

---

## Azure App Registration

To upload apps to Intune, you need an Azure AD App Registration with appropriate permissions.

### Step 1: Create App Registration

1. Navigate to **Azure Portal** → **Azure Active Directory** → **App registrations**
2. Click **+ New registration**
3. **Name:** `PackageFactory-Intune`
4. **Supported account types:** Accounts in this organizational directory only
5. Click **Register**

### Step 2: Configure API Permissions

1. In your app registration, go to **API permissions**
2. Click **+ Add a permission**
3. Select **Microsoft Graph**
4. Choose **Application permissions** (not Delegated!)
5. Add these permissions:

   **Required for app upload and management:**
   - `DeviceManagementApps.ReadWrite.All` - Upload and manage Intune apps
   - `DeviceManagementConfiguration.ReadWrite.All` - Configure app settings

   **Required for dashboard features (Phase 3):**
   - `DeviceManagementManagedDevices.Read.All` - View device deployment status
   - `Group.ReadWrite.All` - Create and assign deployment groups

6. Click **Add permissions**
7. **IMPORTANT:** Click **Grant admin consent** (requires Global Admin or Application Admin)

**Note:** If you only see "Bad Request (400)" or "Forbidden (403)" errors in the dashboard, you likely need to add the Phase 3 permissions and grant admin consent.

### Step 3: Create Client Secret

1. Go to **Certificates & secrets**
2. Click **+ New client secret**
3. **Description:** `PackageFactory Secret`
4. **Expires:** 24 months (or as per policy)
5. Click **Add**
6. **⚠️ IMPORTANT:** Copy the **Value** immediately - you won't see it again!

### Step 4: Copy Required Values

You need these three values for PackageFactory:

| Setting | Where to find it |
|---------|------------------|
| **Tenant ID** | App registration → Overview → Directory (tenant) ID |
| **Client ID** | App registration → Overview → Application (client) ID |
| **Client Secret** | The value you copied in Step 3 |

---

## PackageFactory Configuration

### Option 1: Via Web Interface (Recommended)

1. Open PackageFactory: `http://localhost:8080`
2. Click **⚙️ Settings**
3. Scroll to **Intune Integration**
4. Enter:
   - Tenant ID
   - Client ID
   - Client Secret
5. Click **Test Connection**
6. If successful, click **Save Settings**

### Option 2: Manual Configuration

Edit `Config/settings.json` and add:

```json
{
  "OutputPath": "./Output",
  "CompanyPrefix": "MSP",
  "IntuneIntegration": {
    "TenantId": "your-tenant-id-here",
    "ClientId": "your-client-id-here",
    "ClientSecret": "your-client-secret-here",
    "Enabled": true
  }
}
```

---

## Testing the Connection

### Via Web UI (Recommended):
1. Open PackageFactory: `http://localhost:8080`
2. Go to **Settings** → **Intune Integration**
3. Click **Test Connection** button
4. Wait 2-3 seconds
5. Should show: "✅ Successfully connected to Microsoft Intune! Found X app(s)"

This tests:
- OAuth 2.0 authentication with Microsoft Graph
- API permissions are correctly granted
- Connection to Intune tenant is working

---

## How to Use

### 1. Create Package
Create a package as usual through PackageFactory UI

### 2. Create .intunewin Package
1. Go to **Package List**
2. Find your package
3. Click **Create IntuneWin** button
4. Wait for completion (creates Invoke-AppDeployToolkit.intunewin in Intune subfolder)

### 3. Upload to Intune
1. Click **Upload to Intune** button (🔼 icon)
2. PackageFactory will automatically:
   - Extract encryption metadata from .intunewin
   - Create Win32 app in Intune with full metadata
   - Upload encrypted package to Azure Storage (chunked)
   - Commit file and finalize app
3. Wait ~30-60 seconds for large packages
4. Success! App is now ready in Intune

### 4. Verify in Intune Portal
1. Go to https://intune.microsoft.com
2. Navigate to **Apps** → **Windows** → **Windows Apps**
3. Find your app (e.g., "SCI Google ChromeEnterprise 142.0.7444.603 x64")
4. Status should be **Ready** (not "Your app is not ready yet")
5. You can now assign it to groups!

---

## Security Best Practices

### ✅ DO:
- Store credentials in `settings.json` (excluded from Git)
- Use Client Secret with reasonable expiration (12-24 months)
- Limit API permissions to minimum required
- Use dedicated service account if possible

### ❌ DON'T:
- Commit `settings.json` to Git
- Share credentials via email or chat
- Use personal admin account credentials
- Grant more permissions than needed

---

## Troubleshooting

### "Access Denied" / "Insufficient privileges"
- Verify admin consent was granted for API permissions
- Check if Client Secret is still valid (not expired)
- Ensure Tenant ID is correct
- Required permission: `DeviceManagementApps.ReadWrite.All`

### Dashboard: "Bad Request (400)" when viewing device status
**Error:** `Response status code does not indicate success: 400 (Bad Request)`

**Cause:** Missing permission to read managed devices

**Solution:**
1. Go to Azure Portal → App registrations → PackageFactory-Intune
2. API permissions → Add permission → Microsoft Graph → Application permissions
3. Add: `DeviceManagementManagedDevices.Read.All`
4. Click **Grant admin consent**
5. Refresh PackageFactory dashboard

### Dashboard: "Forbidden (403)" when creating groups
**Error:** `Response status code does not indicate success: 403 (Forbidden)`

**Cause:** Insufficient permissions to create Entra ID groups

**Solution:**
1. Go to Azure Portal → App registrations → PackageFactory-Intune
2. API permissions → Find `Group.Read.All` permission
3. **Remove** `Group.Read.All` if present
4. Add permission → Microsoft Graph → Application permissions
5. Add: `Group.ReadWrite.All` (not just Read)
6. Click **Grant admin consent**
7. Wait 2-3 minutes for permissions to propagate
8. Try creating groups again

### "Authentication failed"
- Double-check all three values (Tenant ID, Client ID, Secret)
- Verify Client Secret was copied correctly (no extra spaces)
- Check if secret has expired in Azure Portal
- Go to Settings → Test Connection to verify

### "Package metadata not found"
- Ensure package was created correctly with metadata.json
- Check that package structure is valid
- Try re-creating the package

### "IntuneWinAppUtil.exe not found"
- Tool is auto-downloaded on first use
- Manual download: https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool
- Place in: `Tools/IntuneWinAppUtil.exe`

### "Upload failed: commitFileFailed"
This error was resolved in latest version. If you still see it:
- Ensure you're using latest PackageFactory version
- Verify .intunewin file was created correctly
- Check Azure Storage connectivity
- Contact support with full error message

### "Could not connect to Microsoft Graph"
- Check internet connection
- Verify no proxy blocking graph.microsoft.com
- Test with: `Test-NetConnection graph.microsoft.com -Port 443`

### Permission Overview

| Feature | Required Permission | Error if Missing |
|---------|-------------------|------------------|
| Upload apps | `DeviceManagementApps.ReadWrite.All` | 403 Forbidden |
| View apps dashboard | `DeviceManagementApps.ReadWrite.All` | 403 Forbidden |
| View device status | `DeviceManagementManagedDevices.Read.All` | 400 Bad Request |
| Create groups | `Group.ReadWrite.All` | 403 Forbidden |
| Assign apps to groups | `DeviceManagementApps.ReadWrite.All` | 403 Forbidden |

---

## What's Next?

✅ **Phase 1-3 Complete:**
- ✅ Complete automated upload to Intune
- ✅ Automatic app creation with metadata
- ✅ Detection rules and commands pre-configured
- ✅ Support for large files (chunked upload)
- ✅ **Intune Apps Dashboard** with search and filters
- ✅ **Device Deployment Status** with detailed device list
- ✅ **Auto-create Deployment Groups** (3 groups per app)
- ✅ **Assignment Management** directly from dashboard
- ✅ Dark theme support

🚀 **Phase 4 - Planned Features:**
- **Supersedence Management**: Configure app relationships and upgrades
- **Update Detection**: Automatically detect when new app versions are available
- **Bulk Assignment**: Assign multiple apps to groups at once
- **Deployment Reports**: Generate reports on deployment success rates
- **App Dependencies**: Configure dependency relationships between apps

---

**© 2025 Ramböck IT - PackageFactory**
