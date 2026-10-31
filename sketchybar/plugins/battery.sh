#!/bin/bash
# Battery level, coloured by charge.
source "$(dirname "$0")/../colors.sh"

batt=$(pmset -g batt)
percent=$(grep -Eo '[0-9]+%' <<<"$batt" | head -1 | tr -d '%')
[ -z "$percent" ] && { sketchybar --set "$NAME" drawing=off; exit 0; }

case $percent in
  9[0-9]|100) icon="󰁹" color=$GREEN ;;
  [6-8][0-9]) icon="󰂀" color=$GREEN ;;
  [3-5][0-9]) icon="󰁾" color=$YELLOW ;;
  [1-2][0-9]) icon="󰁻" color=$PEACH ;;
  *)          icon="󰂃" color=$RED ;;
esac

grep -q 'AC Power' <<<"$batt" && { icon="󰂄"; color=$GREEN; }

sketchybar --animate tanh 15 --set "$NAME" icon="$icon" icon.color="$color" label="${percent}%"
