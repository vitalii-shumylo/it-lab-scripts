#!/usr/bin/env bash
# Create a user on RHEL / Rocky / Alma / Fedora and (optionally) put them in the wheel group,
# which RHEL's sudoers file already trusts.
# Usage: sudo ./create-sudo-user.sh anna [--sudo]
# The password is set interactively with passwd - never put one in this script.
set -euo pipefail

user="${1:?usage: $0 <username> [--sudo]}"
if id "$user" >/dev/null 2>&1; then
  echo "User $user already exists"
else
  useradd "$user"
  passwd "$user"
fi

if [[ "${2:-}" == "--sudo" ]]; then
  grep -qE '^%wheel' /etc/sudoers || echo "Warning: no %wheel line in /etc/sudoers"
  usermod -aG wheel "$user"
fi

id "$user"
sudo -l -U "$user"