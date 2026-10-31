#!/bin/bash
# OmniWM routes only an app's *first* window to its assigned workspace; later
# windows open on the current one. Electron apps such as Discord show a
# short-lived updater window first, so the real window misses out. This runs
# on every windows-changed event and applies the app rules to windows seen for
# the first time, which moves them to their assigned workspace. Windows already
# present on the first run are left alone, so OmniWM's own restore wins at
# login, and a window you move by hand later stays put.
seen="/tmp/omniwm-assign-$USER.seen"

rules=$(omniwmctl query rules --format json 2>/dev/null) || exit 0
windows=$(omniwmctl query windows --format json 2>/dev/null) || exit 0

# <window-id> <workspace> <assigned-workspace or ->   for every window
current=$(jq -r --argjson rules "$rules" '
  ($rules.result.payload.rules
    | map(select(.assignToWorkspace != null and .bundleId != null and .bundleId != ""))
    | map({key: .bundleId, value: .assignToWorkspace}) | from_entries) as $assigned
  | .result.payload.windows[]
  | [.id, .workspace.rawName, ($assigned[.app.bundleId // ""] // "-")] | @tsv' <<<"$windows")

if [ -f "$seen" ]; then
  while IFS=$'\t' read -r id workspace assigned; do
    [ -n "$id" ] || continue
    grep -qxF "$id" "$seen" && continue
    [ "$assigned" != "-" ] && [ "$assigned" != "$workspace" ] && omniwmctl rule apply --window "$id" >/dev/null 2>&1
  done <<<"$current"
fi
cut -f1 <<<"$current" >"$seen"
