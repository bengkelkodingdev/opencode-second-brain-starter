#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
# shellcheck source=scripts/common.sh
. "$ROOT_DIR/scripts/common.sh"

if [ -f "$MANIFEST" ]; then
  die "Second Brain Core is already installed. Run $ROOT_DIR/update.sh instead."
fi

name_from_env=${SECOND_BRAIN_NAME:+yes}
vault_from_env=${SECOND_BRAIN_VAULT:+yes}
name=${SECOND_BRAIN_NAME:-}
vault=${SECOND_BRAIN_VAULT:-}
if [ -z "$name" ]; then
  [ -t 0 ] || die "Noninteractive install requires SECOND_BRAIN_NAME."
  printf 'Your name: '
  IFS= read -r name
fi
if [ -z "$vault" ]; then
  [ -t 0 ] || die "Noninteractive install requires SECOND_BRAIN_VAULT."
  printf 'Existing Obsidian vault path: '
  IFS= read -r vault
fi

reject_unsafe_field "Name" "$name"
reject_unsafe_field "Vault path" "$vault"
"$ROOT_DIR/scripts/check-requirements.sh" "$vault"
vault=$(resolve_existing_dir "$vault")

info ""
info "Ringkasan instalasi:"
info "  Nama          : $name"
info "  Obsidian Vault: $vault"
info "  OpenCode      : $OPENCODE_CONFIG_DIR"
if [ -z "$name_from_env" ] || [ -z "$vault_from_env" ]; then
  printf 'Lanjutkan instalasi? [y/N] '
  IFS= read -r confirmation
  case $confirmation in
    y|Y|yes|YES) ;;
    *) die "Instalasi dibatalkan." ;;
  esac
fi

templates=$ROOT_DIR/templates/opencode
commands_template=$templates/commands
agents_template=$templates/AGENTS.md
vault_templates=$ROOT_DIR/templates/vault
vault_agents_template=$vault_templates/AGENTS.md
[ -d "$commands_template" ] || die "Missing template directory: $commands_template"
[ -f "$agents_template" ] || die "Missing template: $agents_template"
[ -f "$vault_agents_template" ] || die "Missing template: $vault_agents_template"

declare -a template_files=() destinations=() backups=()
while IFS= read -r -d '' source; do
  relative=${source#"$commands_template"/}
  reject_unsafe_field "Template path" "$relative"
  template_files+=("$source")
  destinations+=("$OPENCODE_CONFIG_DIR/commands/$relative")
done < <(find "$commands_template" -type f -print0)
[ "${#template_files[@]}" -gt 0 ] || die "No command templates found in $commands_template"

for destination in "${destinations[@]}"; do
  [ ! -e "$destination" ] || die "Refusing to overwrite existing unmanaged command: $destination"
done

mkdir -p -- "$OPENCODE_CONFIG_DIR/commands" "$CORE_DIR"
if [ -f "$AGENTS_FILE" ]; then
  backups+=("$AGENTS_FILE")
fi
vault_agents=$vault/AGENTS.md
assert_not_symlink "$AGENTS_FILE"
assert_not_symlink "$vault_agents"
if [ -f "$vault_agents" ]; then
  backups+=("$vault_agents")
fi

config_file=
permission_mode=manual
json_vault=$(escape_json_string "$vault")
json_name=$(escape_json_string "$name")
if [ -f "$OPENCODE_CONFIG_DIR/opencode.jsonc" ]; then
  config_file=$OPENCODE_CONFIG_DIR/opencode.jsonc
elif [ -f "$OPENCODE_CONFIG_DIR/opencode.json" ]; then
  config_file=$OPENCODE_CONFIG_DIR/opencode.json
else
  config_file=$OPENCODE_CONFIG_DIR/opencode.jsonc
  permission_mode=managed
fi
[ ! -f "$config_file" ] || backups+=("$config_file")
[ "${#backups[@]}" -eq 0 ] || "$ROOT_DIR/scripts/backup.sh" "${backups[@]}"

for index in "${!template_files[@]}"; do
  destination=${destinations[$index]}
  mkdir -p -- "$(dirname -- "$destination")"
  temporary=$(make_temp_in_dir "$(dirname -- "$destination")")
  render_template "${template_files[$index]}" "$temporary" "$vault" "$name"
  mv -- "$temporary" "$destination"
done

agents_rendered=$(make_temp_file)
render_template "$agents_template" "$agents_rendered" "$vault" "$name"
agents_without_block=$(make_temp_file)
if [ -f "$AGENTS_FILE" ]; then
  strip_managed_block "$AGENTS_FILE" "$agents_without_block" "$AGENTS_BEGIN" "$AGENTS_END"
else
  : > "$agents_without_block"
fi
agents_output=$(make_temp_in_dir "$(dirname -- "$AGENTS_FILE")")
{
  cat "$agents_without_block"
  [ ! -s "$agents_without_block" ] || printf '\n'
  printf '%s\n' "$AGENTS_BEGIN"
  cat "$agents_rendered"
  printf '\n%s\n' "$AGENTS_END"
} > "$agents_output"
mv -- "$agents_output" "$AGENTS_FILE"
rm -f -- "$agents_rendered" "$agents_without_block"

mkdir -p -- "$vault/Inbox" "$vault/Templates"
vault_agents_rendered=$(make_temp_file)
vault_agents_without_block=$(make_temp_file)
render_template "$vault_agents_template" "$vault_agents_rendered" "$vault" "$name"
if [ -f "$vault_agents" ]; then
  strip_managed_block "$vault_agents" "$vault_agents_without_block" "$VAULT_AGENTS_BEGIN" "$VAULT_AGENTS_END"
else
  : > "$vault_agents_without_block"
fi
vault_agents_output=$(make_temp_in_dir "$(dirname -- "$vault_agents")")
{
  cat "$vault_agents_without_block"
  [ ! -s "$vault_agents_without_block" ] || printf '\n'
  printf '%s\n' "$VAULT_AGENTS_BEGIN"
  cat "$vault_agents_rendered"
  printf '\n%s\n' "$VAULT_AGENTS_END"
} > "$vault_agents_output"
mv -- "$vault_agents_output" "$vault_agents"
rm -f -- "$vault_agents_rendered" "$vault_agents_without_block"

for vault_template in Project.md Log.md; do
  destination=$vault/Templates/$vault_template
  if [ ! -e "$destination" ]; then
    cp -- "$vault_templates/Templates/$vault_template" "$destination"
  else
    warn "Template vault sudah ada dan tidak ditimpa: $destination"
  fi
done

if [ "$permission_mode" = managed ]; then
  config_output=$(make_temp_in_dir "$(dirname -- "$config_file")")
  cat > "$config_output" <<EOF
{
$CONFIG_BEGIN
  "\$schema": "https://opencode.ai/config.json",
  "username": "$json_name",
  "share": "disabled",
  "permission": {
    "external_directory": {
      "$json_vault/**": "allow"
    },
    "edit": {
      "*": "allow",
      "$json_vault/**": "ask"
    }
  },
$CONFIG_END
}
EOF
  mv -- "$config_output" "$config_file"
else
  if permission_allows_vault "$config_file" "$json_vault" && permission_prompts_vault_edits "$config_file" "$json_vault"; then
    permission_mode=existing
  else
    print_permission_instructions "$vault" "$config_file"
  fi
fi

manifest_tmp=$(make_temp_in_dir "$CORE_DIR")
{
  printf 'version\t1\n'
  printf 'name\t%s\n' "$name"
  printf 'vault\t%s\n' "$vault"
  printf 'agents\t%s\n' "$AGENTS_FILE"
  printf 'vault_agents\t%s\n' "$vault_agents"
  printf 'config\t%s\n' "$config_file"
  printf 'permission\t%s\n' "$permission_mode"
  for destination in "${destinations[@]}"; do
    printf 'file\t%s\n' "$destination"
  done
} > "$manifest_tmp"
mv -- "$manifest_tmp" "$MANIFEST"

info "Second Brain Core terpasang untuk $name."
"$ROOT_DIR/scripts/verify.sh"
info "Tutup dan buka kembali OpenCode agar konfigurasi baru dimuat."
