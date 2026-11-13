#!/bin/bash
# Applies the mods now and adds a cron job to re-apply them every 4 hours.
set -u

[ "$(id -u)" -eq 0 ] || { echo "Run as root (sudo $0)"; exit 1; }

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
chmod +x "$DIR/apply.sh" "$DIR/uninstall.sh"

"$DIR/apply.sh"

# Replace any old entry (including the earlier /root/pihole-temp version)
(crontab -l 2>/dev/null | grep -v 'pihole-temp/apply.sh\|pihole-sidebar-mods/apply.sh'
 echo "0 */4 * * * $DIR/apply.sh >/dev/null 2>&1") | crontab -

echo "Cron job installed: every 4 hours"
echo "Hard-refresh the Pi-hole admin page (Cmd/Ctrl+Shift+R)"
