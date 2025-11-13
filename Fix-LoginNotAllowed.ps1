<# 
 Fix-LoginNotAllowed.ps1
 Fixes "The sign-in method you're trying to use isn't allowed"
 by repairing local logon rights.

 What it does:
  - Creates C:\Temp\LoginFix
  - Exports current User Rights to secpol-orig.inf
  - Creates a fixed copy with:
        SeInteractiveLogonRight      = Administrators + Users
        SeDenyInteractiveLogonRight  = (empty)
  - Applies it with secedit
  - Writes a log file
#>

$ErrorActionPreference = 'Stop'

# --- Paths ---------------------------------------------------------
$root      = 'C:\Temp\LoginFix'
$exportInf = Join-Path $root 'secpol-orig.inf'
$fixedInf  = Join-Path $root 'secpol-fixed.inf'
$logFile   = Join-Path $root 'Fix-LoginNotAllowed.log'

# --- Prep ----------------------------------------------------------
New-Item -ItemType Directory -Path $root -Force | Out-Null

Start-Transcript -Path $logFile -Append -Force
Write-Host "=== Fix-LoginNotAllowed starting ==="

# 1) Export current User Rights
Write-Host "Exporting current User Rights to $exportInf ..."
secedit /export /areas USER_RIGHTS /cfg "$exportInf" | Out-Null

if (!(Test-Path $exportInf)) {
    Write-Error "Failed to export security policy. Aborting."
}

# 2) Read file and adjust the two relevant lines
$lines = Get-Content -Path $exportInf

# Allow log on locally  -> SeInteractiveLogonRight
# We'll set to Administrators + Users via SIDs:
#   Administrators = *S-1-5-32-544
#   Users          = *S-1-5-32-545   :contentReference[oaicite:1]{index=1}
$allowValue = 'SeInteractiveLogonRight = *S-1-5-32-544,*S-1-5-32-545'

if ($lines -match '^SeInteractiveLogonRight\s*=') {
    $lines = $lines -replace '^SeInteractiveLogonRight\s*=.*', $allowValue
} else {
    $lines += $allowValue
}

# Deny log on locally -> SeDenyInteractiveLogonRight
$denyValue = 'SeDenyInteractiveLogonRight ='

if ($lines -match '^SeDenyInteractiveLogonRight\s*=') {
    $lines = $lines -replace '^SeDenyInteractiveLogonRight\s*=.*', $denyValue
} else {
    $lines += $denyValue
}

# 3) Save fixed INF
$lines | Set-Content -Path $fixedInf -Encoding ASCII
Write-Host "Wrote fixed policy to $fixedInf"

# 4) Apply with secedit (User Rights only)
Write-Host "Applying fixed User Rights (this can take a minute)..."
secedit /configure `
    /db "$env:SystemRoot\Security\Database\secedit.sdb" `
    /cfg "$fixedInf" `
    /areas USER_RIGHTS `
    /quiet

Write-Host ""
Write-Host "Done. A reboot is recommended before testing normal sign-in."
Write-Host "Backup of original policy: $exportInf"
Write-Host "Log file: $logFile"
Write-Host "=== Fix-LoginNotAllowed finished ==="

Stop-Transcript
