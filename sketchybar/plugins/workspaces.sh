#!/bin/bash
# OmniWM workspace pills, like OmniWM's own bar: one pill per workspace that
# has windows (plus the current one), with its number and each tiled window's
# app icon in column order. The current workspace gets a lighter pill and a
# mauve number, the focused window a highlighted tile, and apps with a Dock
# notification count (cached by badges.sh) a red badge on their icon.
#
# Pills are only rebuilt when windows open, close or move; switching workspace
# or focus just restyles the existing items, so the bar doesn't flicker.
source "$(dirname "$0")/../colors.sh"
export LC_ALL=en_US.UTF-8 # ${#badge} counts characters, not bytes

state="/tmp/sketchybar-omniwm-$USER"
lock="$state.lock"
again="$state.again"

# OmniWM fires several events per change. Only one run applies at a time, and
# it reads OmniWM *after* taking the lock, so a burst collapses into the latest
# state instead of replaying every intermediate workspace. A run that finds the
# lock taken just asks the holder to go round once more.
find "$lock" -maxdepth 0 -mtime +5s -exec rmdir {} \; 2>/dev/null # left by a killed run
if ! mkdir "$lock" 2>/dev/null; then
  touch "$again"
  exit 0
fi
holding=1
trap '[ $holding -eq 1 ] && rmdir "$lock" 2>/dev/null' EXIT

update() {
  local workspaces windows layout structure rebuild args
  local kind num name current icons number_color pill_bg ring members k id app focused badge tile tile_pad count badge_w
  workspaces=$(omniwmctl query workspaces --format json 2>/dev/null) || return
  windows=$(omniwmctl query windows --format json 2>/dev/null) || return

  # W <num> <name> <current>                     for each workspace (1-9)
  # A <num> <window-id> <bundle-id> <focused> <badge>   for each tiled window, in column order
  layout=$(
    jq -r '.result.payload.workspaces[] | select(.number != null and .number <= 9)
      | ["W", .number, .displayName, .isCurrent] | @tsv' <<<"$workspaces"
    jq -r --arg badges "$(cat "$state.badges" 2>/dev/null)" '
      ($badges | split("\n") | map(split("\t") | select(length == 2 and (.[1] | test("[0-9]")))
          | {key: (.[0] | ascii_downcase), value: .[1]})
        | from_entries) as $badge
      | .result.payload.windows | map(select(.workspace.number != null and .mode == "tiling"))
      | sort_by(.workspace.number, (.columnIndex // 0), .frame.y)[]
      | ["A", .workspace.number, .id, (.app.bundleId // .app.name), .isFocused,
          ($badge[.app.bundleId // "" | ascii_downcase] // "")] | @tsv' <<<"$windows"
  )
  [ "$layout" = "$(cat "$state.layout" 2>/dev/null)" ] && return

  # Which workspaces are shown, and which windows they hold (ignores focus).
  structure=$(awk -F'\t' '
    $1 == "W" { name[$2] = $3; cur[$2] = $4; order[++n] = $2 }
    $1 == "A" { apps[$2] = apps[$2] " " $3 " " $4 }
    END { for (i = 1; i <= n; i++) { w = order[i]
            if (apps[w] != "" || cur[w] == "true") print w "\t" name[w] "\t" apps[w] } }' <<<"$layout")
  rebuild=0
  [ "$structure" != "$(cat "$state.structure" 2>/dev/null)" ] && rebuild=1

  args=()
  [ $rebuild -eq 1 ] && args+=(--remove '/^ws\./')

  while IFS=$'\t' read -r kind num name current; do
    [ "$kind" = "W" ] || continue
    icons=$(awk -F'\t' -v n="$num" '$1 == "A" && $2 == n' <<<"$layout")
    [ -z "$icons" ] && [ "$current" != "true" ] && continue
    if [ "$current" = "true" ]; then
      number_color=$MAUVE pill_bg=$PILL_BG_ACTIVE ring=$SURFACE0
    else
      number_color=$SUBTEXT pill_bg=$PILL_BG ring=$BASE
    fi

    if [ $rebuild -eq 1 ]; then
      args+=(--add item "ws.$num.gap" left --move "ws.$num.gap" before gap.front
        --set "ws.$num.gap" width=6 icon.drawing=off label.drawing=off background.drawing=off
        --add item "ws.$num" left --move "ws.$num" before gap.front
        --set "ws.$num" icon="$name" label.drawing=off background.drawing=off
          padding_left=6 padding_right=0 icon.padding_left=0 icon.padding_right=6)
    fi
    args+=(--set "ws.$num" icon.color="$number_color")

    members=("ws.$num")
    k=0
    count=$(grep -c . <<<"$icons")
    while IFS=$'\t' read -r _ _ id app focused badge; do
      [ -z "$id" ] && continue
      k=$((k + 1))
      tile=$TRANSPARENT
      [ "$focused" = "true" ] && tile=$SURFACE1
      tile_pad=4
      [ $k -eq "$count" ] && tile_pad=6 # last tile: pill margin
      if [ $rebuild -eq 1 ]; then
        # No explicit width: the item is exactly its image (24pt), so the tile
        # highlight is centred on the icon. 4pt between tiles, 6pt pill margins.
        args+=(--add item "ws.$num.w.$k" left --move "ws.$num.w.$k" before gap.front
          --set "ws.$num.w.$k" icon.drawing=off label.drawing=off
            padding_left=0 padding_right=4
            background.drawing=on background.height=24 background.corner_radius=7
            background.image="app.$app" background.image.drawing=on background.image.scale=0.75
          --add item "ws.$num.w.$k.badge" left --move "ws.$num.w.$k.badge" before gap.front
          --set "ws.$num.w.$k.badge" width=0 padding_right=0 y_offset=9
            icon.drawing=off background.drawing=off
            label.font="SF Pro Rounded:Bold:9.5" label.color="$BASE" label.align=center
            label.padding_left=0 label.padding_right=0 label.background.drawing=on
            label.background.color="$RED" label.background.height=14 label.background.corner_radius=7
            label.background.border_width=2)
      fi
      args+=(--set "ws.$num.w.$k" background.color="$tile")
      # Counts only (Discord's unread "•" is skipped by the jq above). One digit
      # is a circle, more a capsule; it takes no width and is pulled back over
      # the icon so its right edge sits 4pt past the icon's. The ring matches
      # the pill, so the badge reads as cut out of the icon's corner.
      if [ -n "$badge" ]; then
        badge_w=14
        [ ${#badge} -gt 1 ] && badge_w=$((6 + 6 * ${#badge}))
        args+=(--set "ws.$num.w.$k.badge" drawing=on label="$badge" label.width=$badge_w
          label.background.border_color="$ring" padding_left=$((-(tile_pad + badge_w - 4))))
      else
        args+=(--set "ws.$num.w.$k.badge" drawing=off)
      fi
      members+=("ws.$num.w.$k")
    done <<<"$icons"

    if [ $rebuild -eq 1 ]; then
      [ $k -gt 0 ] && args+=(--set "ws.$num.w.$k" padding_right=6) # last tile: pill margin
      args+=(--add bracket "ws.$num.pill" "${members[@]}"
        --set "ws.$num.pill" background.height=30 background.corner_radius=10
          background.border_color="$PILL_BORDER" background.border_width=1
          background.shadow.drawing=on background.shadow.distance=2 background.shadow.color=0x66000000)
    fi
    args+=(--set "ws.$num.pill" background.color="$pill_bg")
  done <<<"$layout"

  # Remember what was applied only once it has been; a failed apply (e.g.
  # SketchyBar mid-reload) must not look up to date to the next run.
  [ ${#args[@]} -gt 0 ] && { sketchybar "${args[@]}" || return; }
  printf '%s' "$layout" >"$state.layout"
  printf '%s' "$structure" >"$state.structure"
}

while :; do
  touch "$lock" # keep a lock that is busy looping from looking abandoned
  rm -f "$again"
  update
  [ -e "$again" ] && continue
  holding=0
  rmdir "$lock" 2>/dev/null
  # A trigger that arrived between the check and the unlock left a marker;
  # pick it up unless another run already has.
  if [ -e "$again" ] && mkdir "$lock" 2>/dev/null; then
    holding=1
    continue
  fi
  break
done
