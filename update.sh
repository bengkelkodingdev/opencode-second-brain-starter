#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
# shellcheck source=scripts/common.sh
. "$ROOT_DIR/scripts/common.sh"

[ -f "$MANIFEST" ] || die "No installation manifest found. Run $ROOT_DIR/install.sh first."
name=$(manifest_value name) || die "Manifest has no name."
vault=$(manifest_value vault) || die "Manifest has no vault."
reject_unsafe_field "Manifest name" "$name"
reject_unsafe_field "Manifest vault" "$vault"
"$ROOT_DIR/scripts/check-requirements.sh" "$vault"
vault=$(resolve_existing_dir "$vault")

commands_template=$ROOT_DIR/templates/opencode/commands
agents_template=$ROOT_DIR/templates/opencode/AGENTS.md
vault_agents_template=$ROOT_DIR/templates/vault/AGENTS.md
[ -d "$commands_template" ] || die "Missing template directory: $commands_template"
[ -f "$agents_template" ] || die "Missing template: $agents_template"
[ -f "$vault_agents_template" ] || die "Missing template: $vault_agents_template"

old_files=$(make_temp_file)
new_files=$(make_temp_file)
awk -F '\t' '$1 == "file" { print substr($0, index($0, "\t") + 1) }' "$MANIFEST" > "$old_files"

declare -a template_files=() destinations=() backups=()
while IFS= read -r -d '' source; do
  relative=${source#"$commands_template"/}
  reject_unsafe_field "Template path" "$relative"
  template_files+=("$source")
  destination=$OPENCODE_CONFIG_DIR/commands/$relative
  destinations+=("$destination")
  printf '%s\n' "$destination" >> "$new_files"
done < <(find "$commands_template" -type f -print0)
[ "${#template_files[@]}" -gt 0 ] || die "No command templates found in $commands_template"

while IFS= read -r destination; do
  [ -n "$destination" ] || continue
  grep -Fxq -- "$destination" "$old_files" || [ ! -e "$destination" ] || \
    die "Refusing to overwrite existing unmanaged command: $destination"
  if [ -f "$destination" ] && grep -Fxq -- "$destination" "$old_files" && ! is_managed_command "$destination"; then
    die "Managed command marker is missing; refusing to overwrite: $destination"
  fi
  [ ! -f "$destination" ] || backups+=("$destination")
done < "$new_files"
while IFS= read -r destination; do
  [ -n "$destination" ] || continue
  if ! grep -Fxq -- "$destination" "$new_files" && [ -f "$destination" ]; then
    if is_managed_command "$destination"; then
      backups+=("$destination")
    else
      warn "Command lama sudah diganti pengguna dan tidak akan dihapus: $destination"
    fi
  fi
done < "$old_files"
[ ! -f "$AGENTS_FILE" ] || backups+=("$AGENTS_FILE")
vault_agents=$(manifest_value vault_agents || printf '%s\n' "$vault/AGENTS.md")
assert_not_symlink "$AGENTS_FILE"
assert_not_symlink "$vault_agents"
[ ! -f "$vault_agents" ] || backups+=("$vault_agents")
config_file=$(manifest_value config || true)
[ -z "$config_file" ] || [ ! -f "$config_file" ] || backups+=("$config_file")
[ "${#backups[@]}" -eq 0 ] || "$ROOT_DIR/scripts/backup.sh" "${backups[@]}"

for index in "${!template_files[@]}"; do
  destination=${destinations[$index]}
  mkdir -p -- "$(dirname -- "$destination")"
  temporary=$(make_temp_in_dir "$(dirname -- "$destination")")
  render_template "${template_files[$index]}" "$temporary" "$vault" "$name"
  mv -- "$temporary" "$destination"
done
while IFS= read -r destination; do
  [ -n "$destination" ] || continue
  if ! grep -Fxq -- "$destination" "$new_files"; then
    if is_managed_command "$destination"; then
      rm -f -- "$destination"
    fi
  fi
done < "$old_files"

agents_rendered=$(make_temp_file)
agents_without_block=$(make_temp_file)
render_template "$agents_template" "$agents_rendered" "$vault" "$name"
[ -f "$AGENTS_FILE" ] || : > "$AGENTS_FILE"
strip_managed_block "$AGENTS_FILE" "$agents_without_block" "$AGENTS_BEGIN" "$AGENTS_END"
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
[ -f "$vault_agents" ] || : > "$vault_agents"
strip_managed_block "$vault_agents" "$vault_agents_without_block" "$VAULT_AGENTS_BEGIN" "$VAULT_AGENTS_END"
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
  [ -e "$destination" ] || cp -- "$ROOT_DIR/templates/vault/Templates/$vault_template" "$destination"
done

permission_mode=$(manifest_value permission || printf '%s\n' manual)
json_vault=$(escape_json_string "$vault")
json_name=$(escape_json_string "$name")
if [ "$permission_mode" = managed ] && [ -f "$config_file" ] && \
   [ "$(count_fixed_line "$CONFIG_BEGIN" "$config_file")" -eq 1 ]; then
  without_config=$(make_temp_file)
  strip_managed_block "$config_file" "$without_config" "$CONFIG_BEGIN" "$CONFIG_END"
  managed_config=$(make_temp_file)
  cat > "$managed_config" <<EOF
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
EOF
  config_output=$(make_temp_in_dir "$(dirname -- "$config_file")")
  awk -v begin="$CONFIG_BEGIN" -v block="$managed_config" '
    $0 == "{" && !inserted {
      print
      while ((getline line < block) > 0) print line
      close(block)
      inserted=1
      next
    }
    { print }
  ' "$without_config" > "$config_output"
  mv -- "$config_output" "$config_file"
  rm -f -- "$without_config" "$managed_config"
elif permission_allows_vault "$config_file" "$json_vault" && permission_prompts_vault_edits "$config_file" "$json_vault"; then
  permission_mode=existing
else
  permission_mode=manual
  print_permission_instructions "$vault" "${config_file:-$OPENCODE_CONFIG_DIR/opencode.jsonc}"
fi

manifest_tmp=$(make_temp_in_dir "$CORE_DIR")
{
  printf 'version\t1\nname\t%s\nvault\t%s\nagents\t%s\n' "$name" "$vault" "$AGENTS_FILE"
  printf 'vault_agents\t%s\n' "$vault_agents"
  printf 'config\t%s\npermission\t%s\n' "$config_file" "$permission_mode"
  while IFS= read -r destination; do printf 'file\t%s\n' "$destination"; done < "$new_files"
} > "$manifest_tmp"
mv -- "$manifest_tmp" "$MANIFEST"
rm -f -- "$old_files" "$new_files"

info "Updated Second Brain Core."
"$ROOT_DIR/scripts/verify.sh"
