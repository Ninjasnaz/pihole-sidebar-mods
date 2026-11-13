#!/bin/bash
# Re-applies Pi-hole sidebar customizations. Safe to run any number of times.
set -u

[ "$(id -u)" -eq 0 ] || { echo "Run as root (sudo $0)"; exit 1; }

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
SB=/var/www/html/admin/scripts/lua/sidebar.lp
JS=/var/www/html/admin/scripts/js/footer.js
SNIPPET="$DIR/temp.snippet"

# 1. CPU temp line (sidebar.lp)
if grep -q 'id="temperature"' "$SB"; then
  echo "Temp line: already applied"
elif grep -q '<span id="memory"></span>' "$SB"; then
  cp "$SB" "$SB.bak"
  sed -i 's|<span id="memory"></span>$|<span id="memory"></span><br>|' "$SB"
  sed -i "/<span id=\"memory\"><\/span><br>/r $SNIPPET" "$SB"
  echo "Temp line: applied"
else
  echo "Temp line: SKIPPED, sidebar.lp layout changed"
fi

# 2. Memory as used / total (footer.js)
if grep -q 'Memory usage:&nbsp;' "$JS"; then
  cp "$JS" "$JS.bak"
  sed -i '/Memory usage:&nbsp;/{s/Memory usage:/Memory:/;n;s|percentRAM.toFixed(1) +|(system.memory.ram.used / 1048576).toFixed(1) + " / " + totalRAM.toFixed(1) +|;n;s|"&thinsp;%"|"\&thinsp;" + totalRAMUnit|}' "$JS"
  echo "Memory line: applied"
elif grep -q 'Memory:&nbsp;' "$JS"; then
  echo "Memory line: already applied"
else
  echo "Memory line: SKIPPED, footer.js layout changed"
fi
