#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

failures=0
check_failure() {
  warn "$1"
  failures=$((failures + 1))
}

command_exists opencode || check_failure "opencode is not available in PATH."
command_exists git || check_failure "git is not available in PATH."
[ -f "$MANIFEST" ] || die "Installation manifest not found: $MANIFEST"

vault=$(manifest_value vault || true)
name=$(manifest_value name || true)
reject_unsafe_field "Manifest name" "$name"
reject_unsafe_field "Manifest vault" "$vault"
if [ -d "$vault" ]; then
  [ -w "$vault" ] || check_failure "Vault is not writable: $vault"
else
  check_failure "Vault does not exist: $vault"
fi

vault_agents=$(manifest_value vault_agents || printf '%s\n' "$vault/AGENTS.md")
if [ -f "$vault_agents" ]; then
  [ "$(count_fixed_line "$VAULT_AGENTS_BEGIN" "$vault_agents")" -eq 1 ] || check_failure "Vault AGENTS managed start marker is missing or duplicated."
  [ "$(count_fixed_line "$VAULT_AGENTS_END" "$vault_agents")" -eq 1 ] || check_failure "Vault AGENTS managed end marker is missing or duplicated."
  managed_block_contains "$vault_agents" "$VAULT_AGENTS_BEGIN" "$VAULT_AGENTS_END" '{{VAULT_PATH}}' && check_failure "Vault AGENTS managed block still contains {{VAULT_PATH}}."
  managed_block_contains "$vault_agents" "$VAULT_AGENTS_BEGIN" "$VAULT_AGENTS_END" '{{USER_NAME}}' && check_failure "Vault AGENTS managed block still contains {{USER_NAME}}."
else
  check_failure "Vault AGENTS file is missing: $vault_agents"
fi
[ -d "$vault/Inbox" ] || check_failure "Vault Inbox directory is missing: $vault/Inbox"
[ -f "$vault/Templates/Project.md" ] || check_failure "Project template is missing from the vault."
[ -f "$vault/Templates/Log.md" ] || check_failure "Log template is missing from the vault."

agents=$(manifest_value agents || true)
if [ -f "$agents" ]; then
  [ "$(count_fixed_line "$AGENTS_BEGIN" "$agents")" -eq 1 ] || check_failure "AGENTS managed start marker is missing or duplicated."
  [ "$(count_fixed_line "$AGENTS_END" "$agents")" -eq 1 ] || check_failure "AGENTS managed end marker is missing or duplicated."
  managed_block_contains "$agents" "$AGENTS_BEGIN" "$AGENTS_END" '{{VAULT_PATH}}' && check_failure "AGENTS managed block still contains {{VAULT_PATH}}."
  managed_block_contains "$agents" "$AGENTS_BEGIN" "$AGENTS_END" '{{USER_NAME}}' && check_failure "AGENTS managed block still contains {{USER_NAME}}."
else
  check_failure "Managed AGENTS file is missing: $agents"
fi

file_count=0
while IFS=$'\t' read -r kind path; do
  [ "$kind" = file ] || continue
  file_count=$((file_count + 1))
  if [ -f "$path" ]; then
    grep -Fq '{{VAULT_PATH}}' "$path" && check_failure "Unrendered vault placeholder in $path"
    grep -Fq '{{USER_NAME}}' "$path" && check_failure "Unrendered user placeholder in $path"
  else
    check_failure "Managed command is missing: $path"
  fi
done < "$MANIFEST"
[ "$file_count" -gt 0 ] || check_failure "Manifest contains no managed commands."

config=$(manifest_value config || true)
permission_mode=$(manifest_value permission || printf '%s\n' manual)
json_vault=$(escape_json_string "$vault")
if [ -n "$config" ] && permission_allows_vault "$config" "$json_vault" && permission_prompts_vault_edits "$config" "$json_vault"; then
  :
elif [ "$permission_mode" = manual ]; then
  warn "Izin external_directory dan/atau edit: ask belum lengkap pada konfigurasi OpenCode yang sudah ada."
  print_permission_instructions "$vault" "${config:-$OPENCODE_CONFIG_DIR/opencode.jsonc}"
else
  check_failure "OpenCode vault permissions are incomplete for $vault/**."
  print_permission_instructions "$vault" "${config:-$OPENCODE_CONFIG_DIR/opencode.jsonc}"
fi

if [ "$failures" -gt 0 ]; then
  die "Verification failed with $failures issue(s)."
fi
info "Verification passed: $(detect_platform); vault=$vault; commands=$file_count"
