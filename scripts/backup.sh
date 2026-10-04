#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

[ "$#" -gt 0 ] || {
  info "No existing files required backup."
  exit 0
}

timestamp=$(date '+%Y%m%d-%H%M%S')
backup_dir=$BACKUP_ROOT/$timestamp-$$
mkdir -p -- "$backup_dir"
index=$backup_dir/index.tsv
: > "$index"

number=0
for source in "$@"; do
  [ -e "$source" ] || continue
  [ -f "$source" ] || die "Refusing to back up non-file path: $source"
  reject_unsafe_field "Backup path" "$source"
  number=$((number + 1))
  destination=$backup_dir/$number-$(basename -- "$source")
  cp -p -- "$source" "$destination"
  printf '%s\t%s\n' "$source" "$destination" >> "$index"
done

if [ "$number" -eq 0 ]; then
  rm -f -- "$index"
  rmdir -- "$backup_dir"
  info "No existing files required backup."
else
  info "Backup created: $backup_dir"
fi
