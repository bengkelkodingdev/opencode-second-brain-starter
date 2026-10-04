#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'
umask 077

COMMON_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
PROJECT_ROOT=$(CDPATH= cd -- "$COMMON_DIR/.." && pwd -P)
OPENCODE_CONFIG_DIR=${XDG_CONFIG_HOME:-"$HOME/.config"}/opencode
CORE_DIR=$OPENCODE_CONFIG_DIR/.second-brain-core
MANIFEST=$CORE_DIR/manifest
BACKUP_ROOT=$OPENCODE_CONFIG_DIR/.second-brain-backups
AGENTS_FILE=$OPENCODE_CONFIG_DIR/AGENTS.md
AGENTS_BEGIN='# >>> second-brain-core (managed; do not edit) >>>'
AGENTS_END='# <<< second-brain-core (managed) <<<'
VAULT_AGENTS_BEGIN='<!-- second-brain-core:start -->'
VAULT_AGENTS_END='<!-- second-brain-core:end -->'
CONFIG_BEGIN='// >>> second-brain-core permission (managed; do not edit) >>>'
CONFIG_END='// <<< second-brain-core permission (managed) <<<'
COMMAND_MARKER='<!-- second-brain-core:managed -->'

info() {
  printf '%s\n' "$*"
}

warn() {
  printf 'WARNING: %s\n' "$*" >&2
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

assert_not_symlink() {
  local path=$1
  [ ! -L "$path" ] || die "Refusing to modify symlink: $path. Replace it with a regular file or install the starter in the symlink target manually."
}

is_managed_command() {
  local path=$1
  [ -f "$path" ] && grep -Fq "$COMMAND_MARKER" "$path"
}

detect_platform() {
  case $(uname -s) in
    Darwin) printf '%s\n' macOS ;;
    Linux)
      if { [ -r /proc/version ] && grep -qi microsoft /proc/version; } || [ -n "${WSL_DISTRO_NAME:-}" ]; then
        printf '%s\n' WSL
      else
        printf '%s\n' Linux
      fi
      ;;
    *) printf '%s\n' unsupported ;;
  esac
}

reject_unsafe_field() {
  local label=$1 value=$2
  [ -n "$value" ] || die "$label must not be empty."
  case $value in
    *$'\n'*|*$'\r'*|*$'\t'*) die "$label must not contain tabs or newlines." ;;
  esac
}

resolve_existing_dir() {
  local path=$1 resolved
  [ -d "$path" ] || die "Directory does not exist: $path"
  resolved=$(CDPATH= cd -- "$path" 2>/dev/null && pwd -P) || die "Cannot resolve directory: $path"
  printf '%s\n' "$resolved"
}

assert_writable_dir() {
  local directory=$1 probe
  [ -w "$directory" ] || die "Directory is not writable: $directory"
  probe=$(mktemp "$directory/.second-brain-write-test.XXXXXX") || die "Cannot create files in: $directory"
  rm -f -- "$probe"
}

make_temp_file() {
  mktemp "${TMPDIR:-/tmp}/second-brain-core.XXXXXX"
}

make_temp_in_dir() {
  local directory=$1
  mktemp "$directory/.second-brain-core.XXXXXX"
}

count_fixed_line() {
  local needle=$1 file=$2
  [ -f "$file" ] || {
    printf '0\n'
    return
  }
  awk -v needle="$needle" '$0 == needle { count++ } END { print count + 0 }' "$file"
}

strip_managed_block() {
  local source=$1 destination=$2 begin=$3 end=$4
  awk -v begin="$begin" -v end="$end" '
    $0 == begin {
      if (inside || found) exit 42
      inside = 1
      found = 1
      next
    }
    $0 == end {
      if (!inside) exit 42
      inside = 0
      next
    }
    !inside { print }
    END {
      if (inside) exit 42
    }
  ' "$source" > "$destination" || die "Malformed or duplicate managed block in $source"
}

managed_block_contains() {
  local source=$1 begin=$2 end=$3 needle=$4
  [ -f "$source" ] || return 1
  awk -v begin="$begin" -v end="$end" -v needle="$needle" '
    $0 == begin { inside = 1; next }
    $0 == end { inside = 0; next }
    inside && index($0, needle) { found = 1 }
    END { exit(found ? 0 : 1) }
  ' "$source"
}

escape_sed_replacement() {
  local value=$1
  value=${value//\\/\\\\}
  value=${value//&/\\&}
  value=${value//|/\\|}
  printf '%s' "$value"
}

escape_json_string() {
  local value=$1
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  printf '%s' "$value"
}

permission_allows_vault() {
  local file=$1 escaped_vault=$2
  [ -f "$file" ] || return 1
  awk -v path="\"$escaped_vault/**\"" '
    index($0, path) && index($0, "\"allow\"") { found = 1 }
    END { exit(found ? 0 : 1) }
  ' "$file"
}

permission_prompts_vault_edits() {
  local file=$1 escaped_vault=$2
  [ -f "$file" ] || return 1
  awk -v path="\"$escaped_vault/**\"" '
    index($0, path) && index($0, "\"ask\"") { found = 1 }
    END { exit(found ? 0 : 1) }
  ' "$file"
}

render_template() {
  local source=$1 destination=$2 vault_path=$3 user_name=$4
  local escaped_vault escaped_name
  escaped_vault=$(escape_sed_replacement "$vault_path")
  escaped_name=$(escape_sed_replacement "$user_name")
  sed -e "s|{{VAULT_PATH}}|$escaped_vault|g" \
      -e "s|{{USER_NAME}}|$escaped_name|g" \
      "$source" > "$destination"
}

manifest_value() {
  local key=$1
  [ -f "$MANIFEST" ] || return 1
  awk -F '\t' -v key="$key" '$1 == key { print substr($0, index($0, "\t") + 1); exit }' "$MANIFEST"
}

print_permission_instructions() {
  local vault=$1 config=${2:-$OPENCODE_CONFIG_DIR/opencode.jsonc} escaped_vault
  escaped_vault=$(escape_json_string "$vault")
  cat >&2 <<EOF

Manual OpenCode permission required in: $config
Merge this entry into the existing top-level "permission" object. Preserve all
existing provider, model, plugin, and permission settings:

  "external_directory": {
    "$escaped_vault/**": "allow"
  },
  "edit": {
    "*": "allow",
    "$escaped_vault/**": "ask"
  }

If these permission objects already exist, merge the vault rules into them.
Then run: "$PROJECT_ROOT/scripts/verify.sh"
EOF
}
