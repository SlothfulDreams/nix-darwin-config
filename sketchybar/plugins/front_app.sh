#!/bin/bash
# Focused app: its real icon and name.
# Look the icon up by bundle id: by name fails for apps outside /Applications
# (e.g. Messages) and falls back to a generic document icon. The label uses
# the name SketchyBar passes with the switch event when there is one.
info=$(lsappinfo info "$(lsappinfo front)")
app=$(sed -nE '1s/^"([^"]*)".*/\1/p' <<<"$info")
bundle=$(sed -nE 's/^.*bundleID="([^"]*)".*$/\1/p' <<<"$info")
[ "$SENDER" = "front_app_switched" ] && [ -n "$INFO" ] && app=$INFO
[ -n "$app" ] && sketchybar --set "$NAME" label="$app" icon.background.image="app.${bundle:-$app}"
