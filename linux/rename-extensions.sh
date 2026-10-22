#!/usr/bin/env bash
# Rename files from one extension to another in the current directory, never overwriting.
# Usage: ./rename-extensions.sh jpeg jpg
set -euo pipefail

from="${1:?usage: $0 <from-ext> <to-ext>}"
to="${2:?usage: $0 <from-ext> <to-ext>}"
shopt -s nullglob
for f in *."$from"; do
  mv -n -- "$f" "${f%."$from"}.$to"
done