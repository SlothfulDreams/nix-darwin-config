#!/bin/bash
# Wi-Fi status. The network name is hidden from command-line tools, so the icon alone
# signals connected / no network / off.
source "$(dirname "$0")/../colors.sh"

iface=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/ { getline; print $2 }')
if [ -n "$(ipconfig getifaddr "$iface" 2>/dev/null)" ]; then
  sketchybar --set "$NAME" icon="󰖩" icon.color=$BLUE label.drawing=off
elif networksetup -getairportpower "$iface" | grep -q 'On$'; then
  sketchybar --set "$NAME" icon="󰖪" icon.color=$OVERLAY0 label="No network" label.drawing=on
else
  sketchybar --set "$NAME" icon="󰖪" icon.color=$OVERLAY0 label="Off" label.drawing=on
fi
