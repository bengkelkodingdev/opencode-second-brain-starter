[CmdletBinding()]
param(
    [string]$Name,
    [string]$VaultPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'scripts\common.ps1')

Assert-NoReparsePath $script:Manifest
if (-not (Test-Path -LiteralPath $script:Manifest -PathType Leaf)) { Stop-WithError 'No installation manifest found. Run install.ps1 first.' }
Assert-ManifestVersion
$manifestName = Get-ManifestValue 'name'
$manifestVault = Get-ManifestValue 'vault'
if (-not $Name) { $Name = if ($env:SECOND_BRAIN_NAME) { $env:SECOND_BRAIN_NAME } else { $manifestName } }
if (-not $VaultPath) { $VaultPath = if ($env:SECOND_BRAIN_VAULT) { $env:SECOND_BRAIN_VAULT } else { $manifestVault } }
Assert-SafeField 'Name' $Name
Assert-SafeField 'Vault path' $VaultPath
$VaultPath = Assert-Requirements $VaultPath
if (-not [StringComparer]::OrdinalIgnoreCase.Equals($VaultPath, (Resolve-ExistingDirectory $manifestVault))) {
    Stop-WithError 'Changing the vault during update is unsafe. Uninstall and reinstall with the new vault path.'
}

$templates = Get-CommandTemplates
$commandsDir = Join-Path $script:OpenCodeConfigDir 'commands'
$destinations = @($templates | ForEach-Object { Join-Path $commandsDir $_.Name })
$oldFiles = @((Get-ManifestRows | Where-Object { $_.Kind -ceq 'file' }).Value)
foreach ($oldFile in $oldFiles) { Assert-ManagedCommandPath $oldFile; Assert-NoReparsePath $oldFile }
foreach ($destination in $destinations) {
    Assert-NoReparsePath $destination
    if ((Test-Path -LiteralPath $destination) -and ($oldFiles -notcontains $destination)) {
        Stop-WithError "Refusing to overwrite existing unmanaged command: $destination"
    }
    if ((Test-Path -LiteralPath $destination -PathType Leaf) -and ($oldFiles -contains $destination) -and -not (Test-ManagedCommand $destination)) {
        Stop-WithError "Managed command marker is missing; refusing to overwrite: $destination"
    }
}

$vaultAgents = Get-ManifestValue 'vault_agents' -Optional
if (-not $vaultAgents) { $vaultAgents = Join-Path $VaultPath 'AGENTS.md' }
$configFile = Get-ManifestValue 'config' -Optional
$permissionMode = Get-ManifestValue 'permission' -Optional
if (-not $permissionMode) { $permissionMode = 'manual' }
Assert-RegularFileOrMissing $script:AgentsFile
Assert-RegularFileOrMissing $vaultAgents
if ($configFile) { Assert-RegularFileOrMissing $configFile }

$backups = @($script:AgentsFile, $vaultAgents, $configFile)
$backups += $oldFiles | Where-Object { (Test-Path -LiteralPath $_ -PathType Leaf) -and (Test-ManagedCommand $_) }
Backup-Files $backups
New-SafeDirectory $commandsDir
for ($i = 0; $i -lt $templates.Count; $i++) {
    Write-AtomicText $destinations[$i] (Render-Template $templates[$i].FullName $VaultPath $Name)
}
foreach ($oldFile in $oldFiles) {
    if (($destinations -notcontains $oldFile) -and (Test-Path -LiteralPath $oldFile)) {
        if (Test-ManagedCommand $oldFile) { Remove-Item -LiteralPath $oldFile -Force }
        else { Write-WarningMessage "Old command was changed by the user and was not removed: $oldFile" }
    }
}

$agentsTemplate = Join-Path $script:ProjectRoot 'templates\opencode\AGENTS.md'
$vaultAgentsTemplate = Join-Path $script:ProjectRoot 'templates\vault\AGENTS.md'
Set-ManagedBlock $script:AgentsFile (Render-Template $agentsTemplate $VaultPath $Name) $script:AgentsBegin $script:AgentsEnd
New-SafeDirectory (Join-Path $VaultPath 'Inbox')
$vaultTemplatesDir = Join-Path $VaultPath 'Templates'
New-SafeDirectory $vaultTemplatesDir
Set-ManagedBlock $vaultAgents (Render-Template $vaultAgentsTemplate $VaultPath $Name) $script:VaultAgentsBegin $script:VaultAgentsEnd
foreach ($templateName in @('Project.md', 'Log.md')) {
    $destination = Join-Path $vaultTemplatesDir $templateName
    Assert-NoReparsePath $destination
    if (-not (Test-Path -LiteralPath $destination)) {
        Write-AtomicText $destination (Get-FileText (Join-Path $script:ProjectRoot "templates\vault\Templates\$templateName"))
    }
}

if ($permissionMode -eq 'managed' -and $configFile -and (Test-Path -LiteralPath $configFile -PathType Leaf)) {
    Assert-ManagedBlock $configFile $script:ConfigBegin $script:ConfigEnd
    if ((Get-MarkerCount $configFile $script:ConfigBegin) -eq 1) {
        $without = Remove-ManagedBlock (Get-FileText $configFile) $script:ConfigBegin $script:ConfigEnd $configFile
        $nameLiteral = ConvertTo-JsonLiteral $Name
        $pathLiteral = ConvertTo-JsonLiteral (Join-Path $VaultPath '**')
        $block = @"
$script:ConfigBegin
  `"`$schema`": `"https://opencode.ai/config.json`",
  `"username`": $nameLiteral,
  `"share`": `"disabled`",
  `"permission`": {
    `"external_directory`": {
      ${pathLiteral}: `"allow`"
    },
    `"edit`": {
      `"*`": `"allow`",
      ${pathLiteral}: `"ask`"
    }
  },
$script:ConfigEnd
"@
        $lines = @($without -split "`r?`n")
        $objectLine = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i].Trim() -ceq '{') { $objectLine = $i; break }
        }
        if ($objectLine -lt 0) { Stop-WithError "Managed config has no top-level object line: $configFile" }
        $before = if ($objectLine -ge 0) { @($lines[0..$objectLine]) } else { @() }
        $after = if ($objectLine + 1 -lt $lines.Count) { @($lines[($objectLine + 1)..($lines.Count - 1)]) } else { @() }
        $updated = (@($before) + @($block) + @($after)) -join "`n"
        Write-AtomicText $configFile ($updated.TrimEnd([char[]]"`r`n") + "`n")
    } else { $permissionMode = 'manual'; Show-PermissionInstructions $VaultPath $configFile }
} elseif ($configFile -and (Test-VaultPermissions $configFile $VaultPath)) {
    $permissionMode = 'existing'
} else {
    $permissionMode = 'manual'
    $instructionPath = if ($configFile) { $configFile } else { Join-Path $script:OpenCodeConfigDir 'opencode.jsonc' }
    Show-PermissionInstructions $VaultPath $instructionPath
}

Write-Manifest $Name $VaultPath $vaultAgents $configFile $permissionMode $destinations
Write-Info 'Updated Second Brain Core.'
& (Join-Path $PSScriptRoot 'scripts\verify.ps1') -Name $Name -VaultPath $VaultPath
