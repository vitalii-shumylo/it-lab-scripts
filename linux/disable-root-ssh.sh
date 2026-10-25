#!/usr/bin/env bash
# Turn off direct root login over SSH and add a small sudo hardening file, without editing sshd_config itself.
# Both changes are drop-in files, are syntax-checked before use, and are removed again if the check fails.
# Target OS: RHEL 9 / 10 and the same family (Rocky, Alma). Run as root or with sudo.
# Make sure a second user with sudo can log in BEFORE you run this, and keep your current session open.
# Full guide: https://learnitlessons.com/articles/disable-root-ssh-login-sudo/?s=github
# Written with AI assistance and checked by the author.
# Usage: sudo ./disable-root-ssh.sh [web-admin-group]
#   web-admin-group  optional group allowed to start/stop/restart httpd through sudo (for example: webops)
set -euo pipefail

group="${1:-}"
ssh_dropin=/etc/ssh/sshd_config.d/00-no-root-login.conf
sudo_dropin=/etc/sudoers.d/10-hardening

echo "Current PermitRootLogin settings:"
grep -ri permitrootlogin /etc/ssh/sshd_config /etc/ssh/sshd_config.d/ || true

echo 'PermitRootLogin no' > "$ssh_dropin"
if sshd -t; then
  sshd -T | grep -i permitrootlogin
  systemctl reload sshd
else
  rm -f "$ssh_dropin"
  echo "sshd -t failed, change reverted" >&2
  exit 1
fi

{
  echo '# Log every sudo command to its own file, and run commands in a pseudo-terminal'
  echo 'Defaults logfile="/var/log/sudo.log"'
  echo 'Defaults use_pty'
  echo '# Ask for the password again after 5 minutes idle'
  echo 'Defaults timestamp_timeout=5'
  if [[ -n "$group" ]]; then
    echo
    echo "# Members of $group can manage httpd, nothing else"
    echo 'Cmnd_Alias WEB_SVC = /usr/bin/systemctl start httpd, /usr/bin/systemctl stop httpd, /usr/bin/systemctl restart httpd, /usr/bin/systemctl status httpd'
    echo "%$group ALL=(root) WEB_SVC"
  fi
} > "$sudo_dropin"
chmod 0440 "$sudo_dropin"
if ! visudo -c; then
  rm -f "$sudo_dropin"
  echo "visudo -c failed, sudoers drop-in removed" >&2
  exit 1
fi
echo "Done. Check the sudo log later with: journalctl _COMM=sudo --since today"
