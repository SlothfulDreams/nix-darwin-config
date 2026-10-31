#!/bin/bash
# Volume.
source "$(dirname "$0")/../colors.sh"

read -r volume muted <<<"$(osascript -e 'set s to get volume settings' \
  -e 'return (output volume of s as text) & " " & (output muted of s as text)')"

color=$TEXT
case $volume in
  [6-9][0-9]|100)   icon="󰕾" ;;
  [3-5][0-9])       icon="󰖀" ;;
  [1-9]|[1-2][0-9]) icon="󰕿" ;;
  *)                icon="󰖁" ;;
esac
if [ "$muted" = "true" ]; then
  icon="󰖁" color=$OVERLAY0
fi

sketchybar --animate tanh 10 --set "$NAME" icon="$icon" label="${volume}%" label.color="$color"
