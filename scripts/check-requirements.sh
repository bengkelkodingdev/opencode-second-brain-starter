#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

vault=${1:-${SECOND_BRAIN_VAULT:-}}
[ -n "$vault" ] || die "Pass a vault path or set SECOND_BRAIN_VAULT."

command_exists opencode || die "opencode is required but was not found in PATH."
command_exists git || die "git is required but was not found in PATH."

platform=$(detect_platform)
[ "$platform" != unsupported ] || die "Only Linux, macOS, and WSL are supported."

vault=$(resolve_existing_dir "$vault")
assert_writable_dir "$vault"

config_parent=$(dirname -- "$OPENCODE_CONFIG_DIR")
if [ -e "$OPENCODE_CONFIG_DIR" ]; then
  [ -d "$OPENCODE_CONFIG_DIR" ] || die "OpenCode config path is not a directory: $OPENCODE_CONFIG_DIR"
  [ -w "$OPENCODE_CONFIG_DIR" ] || die "OpenCode config directory is not writable: $OPENCODE_CONFIG_DIR"
else
  writable_parent=$config_parent
  while [ ! -e "$writable_parent" ]; do
    next_parent=$(dirname -- "$writable_parent")
    [ "$next_parent" != "$writable_parent" ] || die "Cannot find a writable parent for: $OPENCODE_CONFIG_DIR"
    writable_parent=$next_parent
  done
  [ -d "$writable_parent" ] || die "Config parent is not a directory: $writable_parent"
  [ -w "$writable_parent" ] || die "Config parent is not writable: $writable_parent"
fi

info "Requirements OK: $platform; vault=$vault"
