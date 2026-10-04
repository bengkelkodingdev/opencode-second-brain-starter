[CmdletBinding()]
param(
    [string]$Name,
    [string]$VaultPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

$failures = 0
function Add-Failure([string]$Message) {
    $script:failures++
    Write-WarningMessage $Message
}

Assert-NoReparsePath $script:Manifest
if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) { Add-Failure 'opencode is not available in PATH.' }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Add-Failure 'git is not available in PATH.' }
if (-not (Test-Path -LiteralPath $script:Manifest -PathType Leaf)) { Stop-WithError "Installation manifest not found: $script:Manifest" }
Assert-ManifestVersion

$manifestName = Get-ManifestValue 'name'
$manifestVault = Get-ManifestValue 'vault'
if (-not $Name) { $Name = if ($env:SECOND_BRAIN_NAME) { $env:SECOND_BRAIN_NAME } else { $manifestName } }
if (-not $VaultPath) { $VaultPath = if ($env:SECOND_BRAIN_VAULT) { $env:SECOND_BRAIN_VAULT } else { $manifestVault } }
Assert-SafeField 'Name' $Name
Assert-SafeField 'Vault path' $VaultPath

if (Test-Path -LiteralPath $VaultPath -PathType Container) {
    try { Assert-WritableDirectory $VaultPath } catch { Add-Failure $_.Exception.Message }
} else { Add-Failure "Vault does not exist: $VaultPath" }

$vaultAgents = Get-ManifestValue 'vault_agents' -Optional
if (-not $vaultAgents) { $vaultAgents = Join-Path $VaultPath 'AGENTS.md' }
Assert-NoReparsePath $vaultAgents
if (Test-Path -LiteralPath $vaultAgents -PathType Leaf) {
    if ((Get-MarkerCount $vaultAgents $script:VaultAgentsBegin) -ne 1) { Add-Failure 'Vault AGENTS managed start marker is missing or duplicated.' }
    if ((Get-MarkerCount $vaultAgents $script:VaultAgentsEnd) -ne 1) { Add-Failure 'Vault AGENTS managed end marker is missing or duplicated.' }
    if ((Test-ManagedBlockContains $vaultAgents $script:VaultAgentsBegin $script:VaultAgentsEnd '{{VAULT_PATH}}') -or (Test-ManagedBlockContains $vaultAgents $script:VaultAgentsBegin $script:VaultAgentsEnd '{{USER_NAME}}')) { Add-Failure 'Vault AGENTS managed block contains an unrendered placeholder.' }
} else { Add-Failure "Vault AGENTS file is missing: $vaultAgents" }
if (-not (Test-Path -LiteralPath (Join-Path $VaultPath 'Inbox') -PathType Container)) { Add-Failure 'Vault Inbox directory is missing.' }
if (-not (Test-Path -LiteralPath (Join-Path $VaultPath 'Templates\Project.md') -PathType Leaf)) { Add-Failure 'Project template is missing from the vault.' }
if (-not (Test-Path -LiteralPath (Join-Path $VaultPath 'Templates\Log.md') -PathType Leaf)) { Add-Failure 'Log template is missing from the vault.' }

$agents = Get-ManifestValue 'agents' -Optional
if ($agents) { Assert-NoReparsePath $agents }
if ($agents -and (Test-Path -LiteralPath $agents -PathType Leaf)) {
    if ((Get-MarkerCount $agents $script:AgentsBegin) -ne 1) { Add-Failure 'AGENTS managed start marker is missing or duplicated.' }
    if ((Get-MarkerCount $agents $script:AgentsEnd) -ne 1) { Add-Failure 'AGENTS managed end marker is missing or duplicated.' }
    if ((Test-ManagedBlockContains $agents $script:AgentsBegin $script:AgentsEnd '{{VAULT_PATH}}') -or (Test-ManagedBlockContains $agents $script:AgentsBegin $script:AgentsEnd '{{USER_NAME}}')) { Add-Failure 'AGENTS managed block contains an unrendered placeholder.' }
} else { Add-Failure "Managed AGENTS file is missing: $agents" }

$fileCount = 0
foreach ($row in (Get-ManifestRows | Where-Object { $_.Kind -ceq 'file' })) {
    $fileCount++
    try { Assert-ManagedCommandPath $row.Value; Assert-NoReparsePath $row.Value } catch { Add-Failure $_.Exception.Message; continue }
    if (Test-Path -LiteralPath $row.Value -PathType Leaf) {
        $content = Get-FileText $row.Value
        if (-not $content.Contains($script:CommandMarker)) { Add-Failure "Managed command marker is missing: $($row.Value)" }
        if ($content.Contains('{{VAULT_PATH}}') -or $content.Contains('{{USER_NAME}}')) { Add-Failure "Unrendered placeholder in $($row.Value)" }
    } else { Add-Failure "Managed command is missing: $($row.Value)" }
}
if ($fileCount -ne 6) { Add-Failure "Manifest must contain six managed commands; found $fileCount." }

$configFile = Get-ManifestValue 'config' -Optional
$permissionMode = Get-ManifestValue 'permission' -Optional
if ($configFile) { Assert-NoReparsePath $configFile }
if ($configFile -and (Test-VaultPermissions $configFile $VaultPath)) { }
elseif ($permissionMode -eq 'manual') {
    Write-WarningMessage 'OpenCode external_directory and/or edit ask permission is not configured.'
    $instructionPath = if ($configFile) { $configFile } else { Join-Path $script:OpenCodeConfigDir 'opencode.jsonc' }
    Show-PermissionInstructions $VaultPath $instructionPath
} else {
    Add-Failure "OpenCode vault permissions are incomplete for $(Join-Path $VaultPath '**')."
}

if ($failures -gt 0) { Stop-WithError "Verification failed with $failures issue(s)." }
Write-Info "Verification passed: PowerShell $($PSVersionTable.PSVersion); vault=$VaultPath; commands=$fileCount"
