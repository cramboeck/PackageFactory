# ==========================================
# Extended Intune APIs - Groups, Users, Activity
# ==========================================

# This file contains additional API endpoints for:
# - Users Management
# - Enhanced Groups Management
# - Activity History Tracking

# ==========================================
# USERS MANAGEMENT API
# ==========================================

# API: Get all users
Add-PodeRoute -Method Get -Path '/api/intune/users' -ScriptBlock {
    try {
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "GET /api/intune/users - Fetching all users" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan

        # Load config
        $rootPath = $using:RootPath
        $configPath = Join-Path $rootPath "Config\settings.json"
        $config = Get-Content $configPath -Raw | ConvertFrom-Json

        $tenantId = $config.IntuneIntegration.TenantId
        $clientId = $config.IntuneIntegration.ClientId
        $clientSecret = $config.IntuneIntegration.ClientSecret

        # Get access token
        $accessToken = Get-IntuneAccessToken -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret

        $headers = @{
            "Authorization" = "Bearer $accessToken"
            "Content-Type"  = "application/json"
        }

        # Get users with pagination
        $graphUrl = "https://graph.microsoft.com/v1.0/users?`$select=id,displayName,userPrincipalName,mail,department,jobTitle,accountEnabled&`$top=999"
        $allUsers = @()
        $usersResponse = Invoke-RestMethod -Method Get -Uri $graphUrl -Headers $headers -ErrorAction Stop

        if ($usersResponse.value) {
            $allUsers += $usersResponse.value

            # Handle pagination
            while ($usersResponse.'@odata.nextLink') {
                $usersResponse = Invoke-RestMethod -Method Get -Uri $usersResponse.'@odata.nextLink' -Headers $headers
                if ($usersResponse.value) {
                    $allUsers += $usersResponse.value
                }
            }
        }

        Write-Host "✓ Retrieved $($allUsers.Count) user(s)" -ForegroundColor Green

        # Transform for frontend
        $usersList = $allUsers | ForEach-Object {
            @{
                id = $_.id
                displayName = $_.displayName
                userPrincipalName = $_.userPrincipalName
                mail = $_.mail
                department = $_.department
                jobTitle = $_.jobTitle
                accountEnabled = $_.accountEnabled
            }
        }

        Write-PodeJsonResponse -Value @{
            success = $true
            users = @($usersList)
            count = $usersList.Count
        }

    } catch {
        $errorMsg = $_.Exception.Message
        Write-Host "✗ Error fetching users: $errorMsg" -ForegroundColor Red

        Write-PodeJsonResponse -Value @{
            success = $false
            error = "Failed to fetch users: $errorMsg"
        } -StatusCode 500
    }
}

# API: Get user's group memberships
Add-PodeRoute -Method Get -Path '/api/intune/users/:id/groups' -ScriptBlock {
    try {
        $userId = $WebEvent.Parameters['id']

        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "GET /api/intune/users/$userId/groups - Fetching user's groups" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan

        # Load config
        $rootPath = $using:RootPath
        $configPath = Join-Path $rootPath "Config\settings.json"
        $config = Get-Content $configPath -Raw | ConvertFrom-Json

        $tenantId = $config.IntuneIntegration.TenantId
        $clientId = $config.IntuneIntegration.ClientId
        $clientSecret = $config.IntuneIntegration.ClientSecret

        # Get access token
        $accessToken = Get-IntuneAccessToken -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret

        $headers = @{
            "Authorization" = "Bearer $accessToken"
            "Content-Type"  = "application/json"
        }

        # Get user's group memberships
        $graphUrl = "https://graph.microsoft.com/v1.0/users/$userId/memberOf"
        $groupsResponse = Invoke-RestMethod -Method Get -Uri $graphUrl -Headers $headers -ErrorAction Stop

        $groups = @()
        if ($groupsResponse.value) {
            $groups = $groupsResponse.value | Where-Object { $_.'@odata.type' -eq '#microsoft.graph.group' } | ForEach-Object {
                @{
                    id = $_.id
                    displayName = $_.displayName
                    description = $_.description
                }
            }
        }

        Write-Host "✓ User is member of $($groups.Count) group(s)" -ForegroundColor Green

        Write-PodeJsonResponse -Value @{
            success = $true
            groups = @($groups)
            count = $groups.Count
        }

    } catch {
        $errorMsg = $_.Exception.Message
        Write-Host "✗ Error fetching user groups: $errorMsg" -ForegroundColor Red

        Write-PodeJsonResponse -Value @{
            success = $false
            error = "Failed to fetch user groups: $errorMsg"
        } -StatusCode 500
    }
}

# ==========================================
# ENHANCED GROUPS MANAGEMENT API
# ==========================================

# API: Get group members
Add-PodeRoute -Method Get -Path '/api/intune/groups/:id/members' -ScriptBlock {
    try {
        $groupId = $WebEvent.Parameters['id']

        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "GET /api/intune/groups/$groupId/members - Fetching group members" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan

        # Load config
        $rootPath = $using:RootPath
        $configPath = Join-Path $rootPath "Config\settings.json"
        $config = Get-Content $configPath -Raw | ConvertFrom-Json

        $tenantId = $config.IntuneIntegration.TenantId
        $clientId = $config.IntuneIntegration.ClientId
        $clientSecret = $config.IntuneIntegration.ClientSecret

        # Get access token
        $accessToken = Get-IntuneAccessToken -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret

        $headers = @{
            "Authorization" = "Bearer $accessToken"
            "Content-Type"  = "application/json"
        }

        # Get group members
        $graphUrl = "https://graph.microsoft.com/v1.0/groups/$groupId/members"
        $membersResponse = Invoke-RestMethod -Method Get -Uri $graphUrl -Headers $headers -ErrorAction Stop

        $members = @()
        if ($membersResponse.value) {
            $members = $membersResponse.value | ForEach-Object {
                @{
                    id = $_.id
                    displayName = $_.displayName
                    userPrincipalName = $_.userPrincipalName
                    mail = $_.mail
                    type = $_.'@odata.type'
                }
            }
        }

        Write-Host "✓ Group has $($members.Count) member(s)" -ForegroundColor Green

        Write-PodeJsonResponse -Value @{
            success = $true
            members = @($members)
            count = $members.Count
        }

    } catch {
        $errorMsg = $_.Exception.Message
        Write-Host "✗ Error fetching group members: $errorMsg" -ForegroundColor Red

        Write-PodeJsonResponse -Value @{
            success = $false
            error = "Failed to fetch group members: $errorMsg"
        } -StatusCode 500
    }
}

# API: Add member to group
Add-PodeRoute -Method Post -Path '/api/intune/groups/:id/members' -ScriptBlock {
    try {
        $groupId = $WebEvent.Parameters['id']
        $body = $WebEvent.Data
        $userId = $body.userId

        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "POST /api/intune/groups/$groupId/members - Adding member" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan

        if ([string]::IsNullOrWhiteSpace($userId)) {
            Write-PodeJsonResponse -Value @{
                success = $false
                error = "userId is required"
            } -StatusCode 400
            return
        }

        # Load config
        $rootPath = $using:RootPath
        $configPath = Join-Path $rootPath "Config\settings.json"
        $config = Get-Content $configPath -Raw | ConvertFrom-Json

        $tenantId = $config.IntuneIntegration.TenantId
        $clientId = $config.IntuneIntegration.ClientId
        $clientSecret = $config.IntuneIntegration.ClientSecret

        # Get access token
        $accessToken = Get-IntuneAccessToken -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret

        $headers = @{
            "Authorization" = "Bearer $accessToken"
            "Content-Type"  = "application/json"
        }

        # Add member to group
        $memberBody = @{
            "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$userId"
        } | ConvertTo-Json

        $graphUrl = "https://graph.microsoft.com/v1.0/groups/$groupId/members/`$ref"
        Invoke-RestMethod -Method Post -Uri $graphUrl -Headers $headers -Body $memberBody -ErrorAction Stop

        Write-Host "✓ Member added successfully" -ForegroundColor Green

        Write-PodeJsonResponse -Value @{
            success = $true
            message = "Member added to group successfully"
        }

    } catch {
        $errorMsg = $_.Exception.Message
        Write-Host "✗ Error adding member: $errorMsg" -ForegroundColor Red

        Write-PodeJsonResponse -Value @{
            success = $false
            error = "Failed to add member: $errorMsg"
        } -StatusCode 500
    }
}

# API: Remove member from group
Add-PodeRoute -Method Delete -Path '/api/intune/groups/:id/members/:userId' -ScriptBlock {
    try {
        $groupId = $WebEvent.Parameters['id']
        $userId = $WebEvent.Parameters['userId']

        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "DELETE /api/intune/groups/$groupId/members/$userId - Removing member" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan

        # Load config
        $rootPath = $using:RootPath
        $configPath = Join-Path $rootPath "Config\settings.json"
        $config = Get-Content $configPath -Raw | ConvertFrom-Json

        $tenantId = $config.IntuneIntegration.TenantId
        $clientId = $config.IntuneIntegration.ClientId
        $clientSecret = $config.IntuneIntegration.ClientSecret

        # Get access token
        $accessToken = Get-IntuneAccessToken -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret

        $headers = @{
            "Authorization" = "Bearer $accessToken"
            "Content-Type"  = "application/json"
        }

        # Remove member from group
        $graphUrl = "https://graph.microsoft.com/v1.0/groups/$groupId/members/$userId/`$ref"
        Invoke-RestMethod -Method Delete -Uri $graphUrl -Headers $headers -ErrorAction Stop

        Write-Host "✓ Member removed successfully" -ForegroundColor Green

        Write-PodeJsonResponse -Value @{
            success = $true
            message = "Member removed from group successfully"
        }

    } catch {
        $errorMsg = $_.Exception.Message
        Write-Host "✗ Error removing member: $errorMsg" -ForegroundColor Red

        Write-PodeJsonResponse -Value @{
            success = $false
            error = "Failed to remove member: $errorMsg"
        } -StatusCode 500
    }
}

# API: Delete group
Add-PodeRoute -Method Delete -Path '/api/intune/groups/:id' -ScriptBlock {
    try {
        $groupId = $WebEvent.Parameters['id']

        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "DELETE /api/intune/groups/$groupId - Deleting group" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan

        # Load config
        $rootPath = $using:RootPath
        $configPath = Join-Path $rootPath "Config\settings.json"
        $config = Get-Content $configPath -Raw | ConvertFrom-Json

        $tenantId = $config.IntuneIntegration.TenantId
        $clientId = $config.IntuneIntegration.ClientId
        $clientSecret = $config.IntuneIntegration.ClientSecret

        # Get access token
        $accessToken = Get-IntuneAccessToken -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret

        $headers = @{
            "Authorization" = "Bearer $accessToken"
            "Content-Type"  = "application/json"
        }

        # Delete group
        $graphUrl = "https://graph.microsoft.com/v1.0/groups/$groupId"
        Invoke-RestMethod -Method Delete -Uri $graphUrl -Headers $headers -ErrorAction Stop

        Write-Host "✓ Group deleted successfully" -ForegroundColor Green

        Write-PodeJsonResponse -Value @{
            success = $true
            message = "Group deleted successfully"
        }

    } catch {
        $errorMsg = $_.Exception.Message
        Write-Host "✗ Error deleting group: $errorMsg" -ForegroundColor Red

        Write-PodeJsonResponse -Value @{
            success = $false
            error = "Failed to delete group: $errorMsg"
        } -StatusCode 500
    }
}

# ==========================================
# ACTIVITY HISTORY API
# ==========================================

# API: Get activity history
Add-PodeRoute -Method Get -Path '/api/activity/history' -ScriptBlock {
    try {
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "GET /api/activity/history - Fetching activity history" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan

        $rootPath = $using:RootPath
        $dbPath = Join-Path $rootPath "Data\activity-log.db"

        if (-not (Test-Path $dbPath)) {
            Write-PodeJsonResponse -Value @{
                success = $true
                activities = @()
                count = 0
                message = "No activity history yet"
            }
            return
        }

        # Query parameters
        $limit = $WebEvent.Query['limit']
        if ([string]::IsNullOrWhiteSpace($limit)) {
            $limit = 100
        }

        $actionType = $WebEvent.Query['action_type']

        # Load SQLite
        $assemblyPath = Join-Path $rootPath "Assemblies\System.Data.SQLite.dll"
        if (Test-Path $assemblyPath) {
            Add-Type -Path $assemblyPath -ErrorAction SilentlyContinue
        }

        $connectionString = "Data Source=$dbPath;Version=3;"
        $connection = New-Object System.Data.SQLite.SQLiteConnection($connectionString)
        $connection.Open()

        $sql = "SELECT * FROM activity_log"
        if (-not [string]::IsNullOrWhiteSpace($actionType)) {
            $sql += " WHERE action_type = @ActionType"
        }
        $sql += " ORDER BY timestamp DESC LIMIT @Limit"

        $command = $connection.CreateCommand()
        $command.CommandText = $sql
        if (-not [string]::IsNullOrWhiteSpace($actionType)) {
            $command.Parameters.AddWithValue("@ActionType", $actionType) | Out-Null
        }
        $command.Parameters.AddWithValue("@Limit", [int]$limit) | Out-Null

        $adapter = New-Object System.Data.SQLite.SQLiteDataAdapter($command)
        $dataSet = New-Object System.Data.DataSet
        $adapter.Fill($dataSet) | Out-Null

        $connection.Close()

        $activities = @()
        foreach ($row in $dataSet.Tables[0].Rows) {
            $activities += @{
                id = $row["id"]
                timestamp = $row["timestamp"]
                action_type = $row["action_type"]
                app_id = $row["app_id"]
                app_name = $row["app_name"]
                group_id = $row["group_id"]
                group_name = $row["group_name"]
                user_id = $row["user_id"]
                user_name = $row["user_name"]
                intent = $row["intent"]
                details = $row["details"]
                success = [bool]$row["success"]
                error_message = $row["error_message"]
            }
        }

        Write-Host "✓ Retrieved $($activities.Count) activity record(s)" -ForegroundColor Green

        Write-PodeJsonResponse -Value @{
            success = $true
            activities = $activities
            count = $activities.Count
        }

    } catch {
        $errorMsg = $_.Exception.Message
        Write-Host "✗ Error fetching activity history: $errorMsg" -ForegroundColor Red

        Write-PodeJsonResponse -Value @{
            success = $false
            error = "Failed to fetch activity history: $errorMsg"
        } -StatusCode 500
    }
}
