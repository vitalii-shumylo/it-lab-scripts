#!/usr/bin/env bash
# Read-only: show the real settings of a config file (no comments, no empty lines), and optionally find
# where a setting appears anywhere under a folder (file name and line number), without changing anything.
# Requirements: bash and grep. Use sudo if some files are readable only by root.
# Not run against production; review before use.
# Full guide: https://learnitlessons.com/articles/grep-examples-linux/?s=github
# Written with AI assistance and checked by the author.
# Usage: ./show-active-config.sh <config-file>
#        ./show-active-config.sh <folder> <setting-name>
set -u

target="${1:?usage: $0 <config-file> | $0 <folder> <setting-name>}"

if [[ -f "$target" ]]; then
  # First grep removes lines that start with #, the second removes empty lines.
  grep -v '^#' "$target" | grep -v '^$'
elif [[ -d "$target" ]]; then
  setting="${2:?usage: $0 <folder> <setting-name>}"
  # -r searches the whole folder, -n shows line numbers, -F treats the name as plain text.
  grep -rnF -- "$setting" "$target"
  status=$?
  # grep exit status: 0 found, 1 not found, 2 error.
  [[ $status -eq 1 ]] && echo "No match for '$setting' under $target"
  exit $status
else
  echo "Not a file or folder: $target" >&2
  exit 2
fi
