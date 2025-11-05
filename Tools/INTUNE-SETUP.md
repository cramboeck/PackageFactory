# Intune Integration Setup Guide

This guide helps you configure PackageFactory for direct integration with Microsoft Intune.

---

## Prerequisites

### 1. Install IntuneWin32App PowerShell Module

Open PowerShell as Administrator and run:

```powershell
Install-Module -Name IntuneWin32App -Force -Scope CurrentUser
```

**Verify installation:**
```powershell
Get-Module -ListAvailable IntuneWin32App
```

You should see the module listed with version information.

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
   - `DeviceManagementApps.ReadWrite.All`
   - `DeviceManagementConfiguration.ReadWrite.All`
   - `Group.Read.All` (optional, for group assignments)
6. Click **Add permissions**
7. **IMPORTANT:** Click **Grant admin consent** (requires Global Admin or Application Admin)

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

### Via UI:
1. Settings → Intune Integration → **Test Connection** button
2. Wait 2-3 seconds
3. Should show: "✅ Connected successfully"

### Via PowerShell:
```powershell
# Import module
Import-Module IntuneWin32App

# Connect
$TenantId = "your-tenant-id"
$ClientId = "your-client-id"
$ClientSecret = ConvertTo-SecureString "your-secret" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($ClientId, $ClientSecret)

Connect-MSIntuneGraph -TenantId $TenantId -ClientSecret $Credential

# Test: Get first 5 apps
Get-IntuneWin32App | Select-Object -First 5 displayName
```

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

### "Module not found"
```powershell
# Reinstall module
Install-Module -Name IntuneWin32App -Force -AllowClobber
```

### "Access Denied" / "Insufficient privileges"
- Verify admin consent was granted for API permissions
- Check if Client Secret is still valid (not expired)
- Ensure Tenant ID is correct

### "Authentication failed"
- Double-check all three values (Tenant ID, Client ID, Secret)
- Verify Client Secret was copied correctly (no extra spaces)
- Check if secret has expired in Azure Portal

### "Could not connect to Microsoft Graph"
- Check internet connection
- Verify no proxy blocking Microsoft Graph API
- Try manual PowerShell connection to isolate issue

---

## What's Next?

Once authentication works, you can:

✅ Upload packages directly to Intune with one click
✅ View all apps currently in your Intune tenant
✅ Update existing apps with new versions
✅ Configure assignments and deployment settings

---

**© 2025 Ramböck IT - PackageFactory**
