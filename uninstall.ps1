[CmdletBinding()]
param(
    [string]$Name,
    [string]$VaultPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'scripts\common.ps1')

Assert-NoReparsePath $script:Manifest
if (-not (Test-Path -LiteralPath $script:Manifest -PathType Leaf)) { Stop-WithError 'No Second Brain Core installation manifest found.' }
Assert-ManifestVersion
$rows = Get-ManifestRows
$manifestVault = Get-ManifestValue 'vault' -Optional
if (-not $VaultPath) { $VaultPath = if ($env:SECOND_BRAIN_VAULT) { $env:SECOND_BRAIN_VAULT } else { $manifestVault } }
$agents = Get-ManifestValue 'agents' -Optional
if (-not $agents) { $agents = $script:AgentsFile }
$vaultAgents = Get-ManifestValue 'vault_agents' -Optional
$configFile = Get-ManifestValue 'config' -Optional
$permissionMode = Get-ManifestValue 'permission' -Optional
Assert-NoReparsePath $agents
if ($vaultAgents) { Assert-NoReparsePath $vaultAgents }
if ($configFile) { Assert-NoReparsePath $configFile }

Assert-ManagedBlock $agents $script:AgentsBegin $script:AgentsEnd
if ($vaultAgents -and (Test-Path -LiteralPath $vaultAgents -PathType Leaf)) {
    $vaultBeginCount = Get-MarkerCount $vaultAgents $script:VaultAgentsBegin
    $vaultEndCount = Get-MarkerCount $vaultAgents $script:VaultAgentsEnd
    if (($vaultBeginCount -ne 0 -or $vaultEndCount -ne 0) -and ($vaultBeginCount -ne 1 -or $vaultEndCount -ne 1)) {
        Stop-WithError "Malformed managed block in $vaultAgents"
    }
}
if ($permissionMode -eq 'managed' -and $configFile) { Assert-ManagedBlock $configFile $script:ConfigBegin $script:ConfigEnd }

$manifestFiles = @($rows | Where-Object { $_.Kind -ceq 'file' } | ForEach-Object { $_.Value })
foreach ($path in $manifestFiles) { Assert-ManagedCommandPath $path; Assert-NoReparsePath $path }
$managedFiles = @($manifestFiles | Where-Object { Test-ManagedCommand $_ })
$backups = @($managedFiles + @($agents, $vaultAgents))
if ($permissionMode -eq 'managed') { $backups += $configFile }
Backup-Files $backups

foreach ($row in ($rows | Where-Object { $_.Kind -ceq 'file' })) {
    $path = $row.Value
    Assert-NoReparsePath $path
    if (-not (Test-Path -LiteralPath $path)) { continue }
    if (Test-ManagedCommand $path) { Remove-Item -LiteralPath $path -Force }
    else { Write-WarningMessage "File is no longer a managed command and was not removed: $path" }
}

if ((Get-MarkerCount $agents $script:AgentsBegin) -eq 1) {
    $content = Remove-ManagedBlock (Get-FileText $agents) $script:AgentsBegin $script:AgentsEnd $agents
    if ($content.Length -gt 0) { Write-AtomicText $agents ($content + "`n") } else { Remove-Item -LiteralPath $agents -Force }
}
if ($permissionMode -eq 'managed' -and $configFile -and (Get-MarkerCount $configFile $script:ConfigBegin) -eq 1) {
    $content = Remove-ManagedBlock (Get-FileText $configFile) $script:ConfigBegin $script:ConfigEnd $configFile
    Write-AtomicText $configFile ($content.TrimEnd([char[]]"`r`n") + "`n")
}
if ($vaultAgents -and (Test-Path -LiteralPath $vaultAgents -PathType Leaf)) {
    if ((Get-MarkerCount $vaultAgents $script:VaultAgentsBegin) -eq 1) {
        $content = Remove-ManagedBlock (Get-FileText $vaultAgents) $script:VaultAgentsBegin $script:VaultAgentsEnd $vaultAgents
        if ($content.Length -gt 0) { Write-AtomicText $vaultAgents ($content + "`n") } else { Remove-Item -LiteralPath $vaultAgents -Force }
    }
}

Remove-Item -LiteralPath $script:Manifest -Force
if ((Test-Path -LiteralPath $script:CoreDir -PathType Container) -and @((Get-ChildItem -LiteralPath $script:CoreDir -Force)).Count -eq 0) {
    Remove-Item -LiteralPath $script:CoreDir -Force
}
Write-Info 'Uninstalled managed commands and global configuration blocks.'
Write-Info "Project notes, Inbox, and vault templates were not deleted: $VaultPath"
