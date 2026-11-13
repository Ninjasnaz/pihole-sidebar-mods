#!/bin/bash
# Removes the cron job and restores the original Pi-hole files from backup.
set -u

[ "$(id -u)" -eq 0 ] || { echo "Run as root (sudo $0)"; exit 1; }

SB=/var/www/html/admin/scripts/lua/sidebar.lp
JS=/var/www/html/admin/scripts/js/footer.js

(crontab -l 2>/dev/null | grep -v 'pihole-temp/apply.sh\|pihole-sidebar-mods/apply.sh') | crontab -
echo "Cron job removed"

for F in "$SB" "$JS"; do
  if [ -f "$F.bak" ]; then
    cp "$F.bak" "$F" && echo "Restored $F"
  else
    echo "No backup for $F (run 'pihole -r' and choose Repair to reset web files)"
  fi
done

echo "Hard-refresh the Pi-hole admin page (Cmd/Ctrl+Shift+R)"
