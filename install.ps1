[CmdletBinding()]
param(
    [string]$Name,
    [string]$VaultPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'scripts\common.ps1')

$nameProvided = -not [string]::IsNullOrWhiteSpace($Name) -or -not [string]::IsNullOrWhiteSpace($env:SECOND_BRAIN_NAME)
$vaultProvided = -not [string]::IsNullOrWhiteSpace($VaultPath) -or -not [string]::IsNullOrWhiteSpace($env:SECOND_BRAIN_VAULT)
Assert-NoReparsePath $script:Manifest
if (Test-Path -LiteralPath $script:Manifest -PathType Leaf) {
    Stop-WithError "Second Brain Core is already installed. Run update.ps1 instead."
}
if (-not $Name) { $Name = $env:SECOND_BRAIN_NAME }
if (-not $VaultPath) { $VaultPath = $env:SECOND_BRAIN_VAULT }
if (-not $Name) {
    if ([Console]::IsInputRedirected) { Stop-WithError 'Noninteractive install requires -Name or SECOND_BRAIN_NAME.' }
    $Name = Read-Host 'Your name'
}
if (-not $VaultPath) {
    if ([Console]::IsInputRedirected) { Stop-WithError 'Noninteractive install requires -VaultPath or SECOND_BRAIN_VAULT.' }
    $VaultPath = Read-Host 'Existing Obsidian vault path'
}
Assert-SafeField 'Name' $Name
Assert-SafeField 'Vault path' $VaultPath
$VaultPath = Assert-Requirements $VaultPath
Write-Info ''
Write-Info 'Ringkasan instalasi:'
Write-Info "  Nama          : $Name"
Write-Info "  Obsidian Vault: $VaultPath"
Write-Info "  OpenCode      : $script:OpenCodeConfigDir"
if (-not ($nameProvided -and $vaultProvided)) {
    $confirmation = Read-Host 'Lanjutkan instalasi? [y/N]'
    if (@('y', 'yes') -notcontains $confirmation) { Stop-WithError 'Instalasi dibatalkan.' }
}

$templates = Get-CommandTemplates
$agentsTemplate = Join-Path $script:ProjectRoot 'templates\opencode\AGENTS.md'
$vaultAgentsTemplate = Join-Path $script:ProjectRoot 'templates\vault\AGENTS.md'
foreach ($template in @($agentsTemplate, $vaultAgentsTemplate)) {
    if (-not (Test-Path -LiteralPath $template -PathType Leaf)) { Stop-WithError "Missing template: $template" }
}

$commandsDir = Join-Path $script:OpenCodeConfigDir 'commands'
$destinations = @($templates | ForEach-Object { Join-Path $commandsDir $_.Name })
foreach ($destination in $destinations) {
    Assert-NoReparsePath $destination
    if (Test-Path -LiteralPath $destination) { Stop-WithError "Refusing to overwrite existing unmanaged command: $destination" }
}

$vaultAgents = Join-Path $VaultPath 'AGENTS.md'
Assert-RegularFileOrMissing $script:AgentsFile
Assert-RegularFileOrMissing $vaultAgents
$configJsonc = Join-Path $script:OpenCodeConfigDir 'opencode.jsonc'
$configJson = Join-Path $script:OpenCodeConfigDir 'opencode.json'
Assert-RegularFileOrMissing $configJsonc
Assert-RegularFileOrMissing $configJson
$permissionMode = 'manual'
if (Test-Path -LiteralPath $configJsonc -PathType Leaf) { $configFile = $configJsonc }
elseif (Test-Path -LiteralPath $configJson -PathType Leaf) { $configFile = $configJson }
else { $configFile = $configJsonc; $permissionMode = 'managed' }
Assert-RegularFileOrMissing $configFile

$backups = @($script:AgentsFile, $vaultAgents, $configFile) | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf }
Backup-Files $backups
New-SafeDirectory $commandsDir
New-SafeDirectory $script:CoreDir
Write-Manifest $Name $VaultPath $vaultAgents $configFile $permissionMode $destinations

for ($i = 0; $i -lt $templates.Count; $i++) {
    Write-AtomicText $destinations[$i] (Render-Template $templates[$i].FullName $VaultPath $Name)
}
Set-ManagedBlock $script:AgentsFile (Render-Template $agentsTemplate $VaultPath $Name) $script:AgentsBegin $script:AgentsEnd
New-SafeDirectory (Join-Path $VaultPath 'Inbox')
$vaultTemplatesDir = Join-Path $VaultPath 'Templates'
New-SafeDirectory $vaultTemplatesDir
Set-ManagedBlock $vaultAgents (Render-Template $vaultAgentsTemplate $VaultPath $Name) $script:VaultAgentsBegin $script:VaultAgentsEnd
foreach ($templateName in @('Project.md', 'Log.md')) {
    $source = Join-Path $script:ProjectRoot "templates\vault\Templates\$templateName"
    $destination = Join-Path $vaultTemplatesDir $templateName
    Assert-NoReparsePath $destination
    if (-not (Test-Path -LiteralPath $destination)) { Write-AtomicText $destination (Get-FileText $source) }
    else { Write-WarningMessage "Vault template already exists and was not overwritten: $destination" }
}

if ($permissionMode -eq 'managed') {
    $nameLiteral = ConvertTo-JsonLiteral $Name
    $pathLiteral = ConvertTo-JsonLiteral (Join-Path $VaultPath '**')
    $config = @"
{
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
}
"@
    Write-AtomicText $configFile ($config + "`n")
} elseif (Test-VaultPermissions $configFile $VaultPath) {
    $permissionMode = 'existing'
} else {
    Show-PermissionInstructions $VaultPath $configFile
}

Write-Manifest $Name $VaultPath $vaultAgents $configFile $permissionMode $destinations
Write-Info "Second Brain Core installed for $Name."
& (Join-Path $PSScriptRoot 'scripts\verify.ps1') -Name $Name -VaultPath $VaultPath
Write-Info 'Restart OpenCode so the new configuration is loaded.'
