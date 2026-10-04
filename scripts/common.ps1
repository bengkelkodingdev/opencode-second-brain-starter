Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$script:ProjectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$homePath = if ($env:HOME) { $env:HOME } else { [Environment]::GetFolderPath('UserProfile') }
$configHome = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $homePath '.config' }
$script:OpenCodeConfigDir = Join-Path $configHome 'opencode'
$script:CoreDir = Join-Path $script:OpenCodeConfigDir '.second-brain-core'
$script:Manifest = Join-Path $script:CoreDir 'manifest'
$script:BackupRoot = Join-Path $script:OpenCodeConfigDir '.second-brain-backups'
$script:AgentsFile = Join-Path $script:OpenCodeConfigDir 'AGENTS.md'
$script:AgentsBegin = '# >>> second-brain-core (managed; do not edit) >>>'
$script:AgentsEnd = '# <<< second-brain-core (managed) <<<'
$script:VaultAgentsBegin = '<!-- second-brain-core:start -->'
$script:VaultAgentsEnd = '<!-- second-brain-core:end -->'
$script:ConfigBegin = '// >>> second-brain-core permission (managed; do not edit) >>>'
$script:ConfigEnd = '// <<< second-brain-core permission (managed) <<<'
$script:CommandMarker = '<!-- second-brain-core:managed -->'
$script:Utf8NoBom = New-Object Text.UTF8Encoding($false)

function Write-Info([string]$Message) { Write-Host $Message }
function Write-WarningMessage([string]$Message) { [Console]::Error.WriteLine("WARNING: $Message") }
function Stop-WithError([string]$Message) { throw $Message }

function Assert-SafeField([string]$Label, [string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) { Stop-WithError "$Label must not be empty." }
    if ($Value.IndexOfAny([char[]]@("`t", "`r", "`n")) -ge 0) {
        Stop-WithError "$Label must not contain tabs or newlines."
    }
}

function Assert-NoReparsePath([string]$Path) {
    $resolved = [IO.Path]::GetFullPath($Path)
    if (Test-Path -LiteralPath $resolved) {
        $item = Get-Item -LiteralPath $resolved -Force
        $linkTypeProperty = $item.PSObject.Properties['LinkType']
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 -and $null -ne $linkTypeProperty -and $linkTypeProperty.Value) {
            Stop-WithError "Refusing to replace symlink or junction: $($item.FullName)"
        }
    }
}

function Assert-RegularFileOrMissing([string]$Path) {
    Assert-NoReparsePath $Path
    if ((Test-Path -LiteralPath $Path) -and -not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Stop-WithError "Expected a regular file or missing path: $Path"
    }
}

function Resolve-ExistingDirectory([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        Stop-WithError "Directory does not exist: $Path"
    }
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.PSProvider.Name -ne 'FileSystem') { Stop-WithError "Not a filesystem directory: $Path" }
    return $item.FullName
}

function Assert-WritableDirectory([string]$Path) {
    $probe = Join-Path $Path ('.second-brain-write-test.' + [Guid]::NewGuid().ToString('N'))
    try {
        $stream = [IO.File]::Create($probe)
        $stream.Dispose()
    } catch {
        Stop-WithError "Directory is not writable: $Path"
    } finally {
        if (Test-Path -LiteralPath $probe) { Remove-Item -LiteralPath $probe -Force }
    }
}

function Assert-Requirements([string]$VaultPath) {
    if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) { Stop-WithError 'opencode is required but was not found in PATH.' }
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Stop-WithError 'git is required but was not found in PATH.' }
    $resolved = Resolve-ExistingDirectory $VaultPath
    Assert-WritableDirectory $resolved
    Assert-NoReparsePath $script:OpenCodeConfigDir
    $ancestor = $script:OpenCodeConfigDir
    while (-not (Test-Path -LiteralPath $ancestor)) {
        $parent = [IO.Directory]::GetParent($ancestor)
        if ($null -eq $parent) { Stop-WithError "Cannot find a writable parent for: $script:OpenCodeConfigDir" }
        $ancestor = $parent.FullName
    }
    if (-not (Test-Path -LiteralPath $ancestor -PathType Container)) { Stop-WithError "Config parent is not a directory: $ancestor" }
    Assert-WritableDirectory $ancestor
    return $resolved
}

function New-SafeDirectory([string]$Path) {
    Assert-NoReparsePath $Path
    if (-not (Test-Path -LiteralPath $Path)) { [IO.Directory]::CreateDirectory([IO.Path]::GetFullPath($Path)) | Out-Null }
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { Stop-WithError "Path is not a directory: $Path" }
    Assert-NoReparsePath $Path
}

function Get-FileText([string]$Path) { return [IO.File]::ReadAllText($Path) }

function Write-AtomicText([string]$Path, [string]$Content) {
    Assert-RegularFileOrMissing $Path
    $fullPath = [IO.Path]::GetFullPath($Path)
    $directory = [IO.Path]::GetDirectoryName($fullPath)
    New-SafeDirectory $directory
    $temporary = Join-Path $directory ('.second-brain-core.' + [Guid]::NewGuid().ToString('N'))
    $replacementBackup = Join-Path $directory ('.second-brain-core-backup.' + [Guid]::NewGuid().ToString('N'))
    try {
        [IO.File]::WriteAllText($temporary, $Content, $script:Utf8NoBom)
        if ([IO.File]::Exists($fullPath)) {
            [IO.File]::Replace($temporary, $fullPath, $replacementBackup)
            [IO.File]::Delete($replacementBackup)
        } else {
            [IO.File]::Move($temporary, $fullPath)
        }
    } finally {
        if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
        if (Test-Path -LiteralPath $replacementBackup) { Remove-Item -LiteralPath $replacementBackup -Force }
    }
}

function Render-Template([string]$Source, [string]$VaultPath, [string]$UserName) {
    return (Get-FileText $Source).Replace('{{VAULT_PATH}}', $VaultPath).Replace('{{USER_NAME}}', $UserName)
}

function Get-MarkerCount([string]$Path, [string]$Marker) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return 0 }
    $lines = (Get-FileText $Path) -split "`r?`n"
    return @($lines | Where-Object { $_ -ceq $Marker }).Count
}

function Remove-ManagedBlock([string]$Content, [string]$Begin, [string]$End, [string]$Path) {
    $inside = $false
    $found = $false
    $output = New-Object Collections.Generic.List[string]
    foreach ($line in ($Content -split "`r?`n")) {
        if ($line -ceq $Begin) {
            if ($inside -or $found) { Stop-WithError "Malformed or duplicate managed block in $Path" }
            $inside = $true
            $found = $true
            continue
        }
        if ($line -ceq $End) {
            if (-not $inside) { Stop-WithError "Malformed or duplicate managed block in $Path" }
            $inside = $false
            continue
        }
        if (-not $inside) { $output.Add($line) }
    }
    if ($inside) { Stop-WithError "Malformed or duplicate managed block in $Path" }
    return (($output -join "`n").TrimEnd([char[]]"`r`n"))
}

function Test-ManagedBlockContains([string]$Path, [string]$Begin, [string]$End, [string]$Needle) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    $inside = $false
    foreach ($line in ((Get-FileText $Path) -split "`r?`n")) {
        if ($line -ceq $Begin) { $inside = $true; continue }
        if ($line -ceq $End) { $inside = $false; continue }
        if ($inside -and $line.Contains($Needle)) { return $true }
    }
    return $false
}

function Set-ManagedBlock([string]$Path, [string]$Rendered, [string]$Begin, [string]$End) {
    Assert-NoReparsePath $Path
    $existing = if (Test-Path -LiteralPath $Path -PathType Leaf) { Get-FileText $Path } else { '' }
    $base = Remove-ManagedBlock $existing $Begin $End $Path
    $prefix = if ($base.Length -gt 0) { $base + "`n`n" } else { '' }
    Write-AtomicText $Path ($prefix + $Begin + "`n" + $Rendered.TrimEnd([char[]]"`r`n") + "`n" + $End + "`n")
}

function Test-ManagedCommand([string]$Path) {
    return (Test-Path -LiteralPath $Path -PathType Leaf) -and ((Get-FileText $Path).Contains($script:CommandMarker))
}

function Assert-ManagedCommandPath([string]$Path) {
    $separators = [char[]]@([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
    $commandsRoot = [IO.Path]::GetFullPath((Join-Path $script:OpenCodeConfigDir 'commands')).TrimEnd($separators) + [IO.Path]::DirectorySeparatorChar
    $candidate = [IO.Path]::GetFullPath($Path)
    if (-not $candidate.StartsWith($commandsRoot, [StringComparison]::OrdinalIgnoreCase)) {
        Stop-WithError "Manifest command path is outside the OpenCode commands directory: $Path"
    }
}

function ConvertTo-JsonLiteral([string]$Value) {
    return (ConvertTo-Json -InputObject $Value -Compress)
}

function Test-VaultPermissions([string]$ConfigPath, [string]$VaultPath) {
    if ([string]::IsNullOrEmpty($ConfigPath) -or -not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) { return $false }
    $content = Get-FileText $ConfigPath
    $pathLiteral = ConvertTo-JsonLiteral (Join-Path $VaultPath '**')
    $escaped = [regex]::Escape($pathLiteral)
    return [regex]::IsMatch($content, $escaped + '\s*:\s*"allow"') -and [regex]::IsMatch($content, $escaped + '\s*:\s*"ask"')
}

function Show-PermissionInstructions([string]$VaultPath, [string]$ConfigPath) {
    $pathLiteral = ConvertTo-JsonLiteral (Join-Path $VaultPath '**')
    [Console]::Error.WriteLine(@"

Manual OpenCode permission required in: $ConfigPath
Merge these entries into the existing top-level "permission" object while
preserving all existing provider, model, plugin, and permission settings:

  "external_directory": {
    ${pathLiteral}: "allow"
  },
  "edit": {
    "*": "allow",
    ${pathLiteral}: "ask"
  }

Then run: powershell -File "$script:ProjectRoot\scripts\verify.ps1"
"@)
}

function Get-ManifestRows {
    if (-not (Test-Path -LiteralPath $script:Manifest -PathType Leaf)) { Stop-WithError "Installation manifest not found: $script:Manifest" }
    $rows = @()
    foreach ($line in ((Get-FileText $script:Manifest) -split "`r?`n")) {
        if (-not $line) { continue }
        $parts = $line -split "`t", 2
        if ($parts.Count -ne 2) { Stop-WithError "Malformed installation manifest: $script:Manifest" }
        $rows += [pscustomobject]@{ Kind = $parts[0]; Value = $parts[1] }
    }
    return $rows
}

function Assert-ManifestVersion {
    $versions = @(Get-ManifestRows | Where-Object { $_.Kind -ceq 'version' })
    if ($versions.Count -ne 1 -or $versions[0].Value -ne '1') {
        Stop-WithError "Unsupported or malformed manifest version: $script:Manifest"
    }
}

function Get-ManifestValue([string]$Key, [switch]$Optional) {
    $row = Get-ManifestRows | Where-Object { $_.Kind -ceq $Key } | Select-Object -First 1
    if ($null -eq $row) {
        if ($Optional) { return $null }
        Stop-WithError "Manifest has no $Key."
    }
    return $row.Value
}

function Write-Manifest([string]$Name, [string]$VaultPath, [string]$VaultAgents, [string]$ConfigPath, [string]$PermissionMode, [string[]]$Files) {
    Assert-SafeField 'Name' $Name
    Assert-SafeField 'Vault path' $VaultPath
    $lines = @("version`t1", "name`t$Name", "vault`t$VaultPath", "agents`t$script:AgentsFile", "vault_agents`t$VaultAgents", "config`t$ConfigPath", "permission`t$PermissionMode")
    foreach ($file in $Files) { $lines += "file`t$file" }
    Write-AtomicText $script:Manifest (($lines -join "`n") + "`n")
}

function Backup-Files([string[]]$Paths) {
    $existing = @($Paths | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -Unique)
    if ($existing.Count -eq 0) { return }
    $backupDir = Join-Path $script:BackupRoot ((Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + $PID + '-' + [Guid]::NewGuid().ToString('N').Substring(0, 8))
    New-SafeDirectory $backupDir
    $index = New-Object Collections.Generic.List[string]
    $number = 0
    foreach ($source in $existing) {
        Assert-SafeField 'Backup path' $source
        Assert-NoReparsePath $source
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { Stop-WithError "Refusing to back up non-file path: $source" }
        $number++
        $destination = Join-Path $backupDir ("$number-" + [IO.Path]::GetFileName($source))
        [IO.File]::Copy([IO.Path]::GetFullPath($source), [IO.Path]::GetFullPath($destination), $false)
        $index.Add("$source`t$destination")
    }
    Write-AtomicText (Join-Path $backupDir 'index.tsv') (($index -join "`n") + "`n")
    Write-Info "Backup created: $backupDir"
}

function Get-CommandTemplates {
    $directory = Join-Path $script:ProjectRoot 'templates\opencode\commands'
    if (-not (Test-Path -LiteralPath $directory -PathType Container)) { Stop-WithError "Missing template directory: $directory" }
    $files = @(Get-ChildItem -LiteralPath $directory -File | Sort-Object Name)
    if ($files.Count -ne 6) { Stop-WithError "Expected six command templates in $directory; found $($files.Count)." }
    return $files
}

function Assert-ManagedBlock([string]$Path, [string]$Begin, [string]$End) {
    $beginCount = Get-MarkerCount $Path $Begin
    $endCount = Get-MarkerCount $Path $End
    if (($beginCount -ne 0 -or $endCount -ne 0) -and ($beginCount -ne 1 -or $endCount -ne 1)) {
        Stop-WithError "Malformed managed block in $Path"
    }
}
