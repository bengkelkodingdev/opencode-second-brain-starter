#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
# shellcheck source=scripts/common.sh
. "$ROOT_DIR/scripts/common.sh"

[ -f "$MANIFEST" ] || die "No Second Brain Core installation manifest found."
vault=$(manifest_value vault || true)
agents=$(manifest_value agents || printf '%s\n' "$AGENTS_FILE")
config=$(manifest_value config || true)
permission_mode=$(manifest_value permission || true)
vault_agents=$(manifest_value vault_agents || true)
assert_not_symlink "$agents"
[ -z "$vault_agents" ] || assert_not_symlink "$vault_agents"

agents_begin_count=0
agents_end_count=0
if [ -f "$agents" ]; then
  agents_begin_count=$(count_fixed_line "$AGENTS_BEGIN" "$agents")
  agents_end_count=$(count_fixed_line "$AGENTS_END" "$agents")
  if [ "$agents_begin_count" -ne 0 ] || [ "$agents_end_count" -ne 0 ]; then
    [ "$agents_begin_count" -eq 1 ] && [ "$agents_end_count" -eq 1 ] || \
      die "Malformed managed block in $agents"
  fi
fi
config_begin_count=0
config_end_count=0
if [ "$permission_mode" = managed ] && [ -n "$config" ] && [ -f "$config" ]; then
  config_begin_count=$(count_fixed_line "$CONFIG_BEGIN" "$config")
  config_end_count=$(count_fixed_line "$CONFIG_END" "$config")
  if [ "$config_begin_count" -ne 0 ] || [ "$config_end_count" -ne 0 ]; then
    [ "$config_begin_count" -eq 1 ] && [ "$config_end_count" -eq 1 ] || \
      die "Malformed managed permission block in $config"
  fi
fi
vault_agents_begin_count=0
vault_agents_end_count=0
if [ -n "$vault_agents" ] && [ -f "$vault_agents" ]; then
  vault_agents_begin_count=$(count_fixed_line "$VAULT_AGENTS_BEGIN" "$vault_agents")
  vault_agents_end_count=$(count_fixed_line "$VAULT_AGENTS_END" "$vault_agents")
  [ "$vault_agents_begin_count" -eq 1 ] && [ "$vault_agents_end_count" -eq 1 ] || \
    die "Malformed managed block in $vault_agents"
fi

declare -a backups=()
while IFS=$'\t' read -r kind path; do
  [ "$kind" != file ] || [ ! -f "$path" ] || ! is_managed_command "$path" || backups+=("$path")
done < "$MANIFEST"
[ ! -f "$agents" ] || backups+=("$agents")
if [ "$permission_mode" = managed ] && [ -n "$config" ] && [ -f "$config" ]; then
  backups+=("$config")
fi
[ -z "$vault_agents" ] || [ ! -f "$vault_agents" ] || backups+=("$vault_agents")
[ "${#backups[@]}" -eq 0 ] || "$ROOT_DIR/scripts/backup.sh" "${backups[@]}"

while IFS=$'\t' read -r kind path; do
  if [ "$kind" = file ] && [ -n "$path" ]; then
    if [ ! -e "$path" ]; then
      continue
    elif is_managed_command "$path"; then
      rm -f -- "$path"
    else
      warn "File bukan lagi command terkelola dan tidak dihapus: $path"
    fi
  fi
done < "$MANIFEST"

if [ -f "$agents" ]; then
  if [ "$agents_begin_count" -ne 0 ] || [ "$agents_end_count" -ne 0 ]; then
    temporary=$(make_temp_in_dir "$(dirname -- "$agents")")
    strip_managed_block "$agents" "$temporary" "$AGENTS_BEGIN" "$AGENTS_END"
    if [ -s "$temporary" ]; then
      mv -- "$temporary" "$agents"
    else
      rm -f -- "$temporary" "$agents"
    fi
  fi
fi

if [ "$permission_mode" = managed ] && [ -n "$config" ] && [ -f "$config" ]; then
  if [ "$config_begin_count" -ne 0 ] || [ "$config_end_count" -ne 0 ]; then
    temporary=$(make_temp_in_dir "$(dirname -- "$config")")
    strip_managed_block "$config" "$temporary" "$CONFIG_BEGIN" "$CONFIG_END"
    mv -- "$temporary" "$config"
  fi
fi

if [ -n "$vault_agents" ] && [ -f "$vault_agents" ]; then
  temporary=$(make_temp_in_dir "$(dirname -- "$vault_agents")")
  strip_managed_block "$vault_agents" "$temporary" "$VAULT_AGENTS_BEGIN" "$VAULT_AGENTS_END"
  if [ -s "$temporary" ]; then
    mv -- "$temporary" "$vault_agents"
  else
    rm -f -- "$temporary" "$vault_agents"
  fi
fi

rm -f -- "$MANIFEST"
rmdir -- "$CORE_DIR" 2>/dev/null || true
info "Uninstalled managed commands and global configuration blocks."
info "Catatan projek, Inbox, dan template vault tidak dihapus: ${vault:-unknown}"
