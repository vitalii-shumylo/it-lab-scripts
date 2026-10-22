#!/usr/bin/env bash
# Ping every host listed in a file (one per line) and print up / DOWN.
# Usage: ./ping-hosts.sh hosts.txt
set -u

file="${1:?usage: $0 <hosts-file>}"
while IFS= read -r host; do
  [[ -z "$host" || "$host" == \#* ]] && continue
  if ping -c 1 -W 1 "$host" > /dev/null 2>&1; then
    echo "$host up"
  else
    echo "$host DOWN"
  fi
done < "$file"