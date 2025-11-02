<#
.SYNOPSIS
    Generates Files directory README content
.DESCRIPTION
    Creates README for the Files directory
#>
function Get-FilesReadmeContent {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string]$MsiFilename,
        [string]$ExeFilename
    )

    $filename = if ($MsiFilename) { $MsiFilename } else { $ExeFilename }

    return @"
# Installation Files

## Required Files

### $filename
**Action:** Download installer and place here

### Config/ (Optional)
**Action:** Add configuration files if needed

---

**© 2025 Ramböck IT**
"@
}
