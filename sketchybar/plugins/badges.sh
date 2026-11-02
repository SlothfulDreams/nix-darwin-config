#!/bin/bash
# Polls the Dock's notification badges (like OmniWM's bar does) and has the
# workspace pills redrawn when they change. Runs from SketchyBar so the helper
# inherits its Accessibility permission.
state="/tmp/sketchybar-omniwm-$USER"

badges=$(sketchybar-dockbadges) || exit 0
[ "$badges" = "$(cat "$state.badges" 2>/dev/null)" ] && exit 0
printf '%s' "$badges" >"$state.badges.tmp" && mv "$state.badges.tmp" "$state.badges"
sketchybar --trigger omniwm_update
