#!/usr/bin/env bash
# Simple numbered log rotation: app.log -> app.log.1 -> ... -> app.log.5 (the oldest is overwritten).
# Usage: ./rotate-log.sh /var/log/myapp/app.log
set -euo pipefail

log="${1:?usage: $0 <logfile>}"
for i in {4..1}; do
  if [[ -f "$log.$i" ]]; then
    mv -- "$log.$i" "$log.$((i + 1))"
  fi
done
[[ -f "$log" ]] && mv -- "$log" "$log.1"
: > "$log"