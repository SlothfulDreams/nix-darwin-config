#!/bin/bash

# AeroSpace can float a panel, but it cannot position floating windows. Center
# the named panel over the largest other window owned by the same application.
sleep 0.2

app_bundle_id=${1:-}
panel_title=${2:-}

if [[ -z "$app_bundle_id" || -z "$panel_title" ]]; then
    exit 0
fi

/usr/bin/osascript - "$app_bundle_id" "$panel_title" <<'APPLESCRIPT'
on run argv
    set appBundleId to item 1 of argv
    set panelTitle to item 2 of argv

    tell application "System Events"
        set matchingProcesses to every application process whose bundle identifier is appBundleId
        if (count of matchingProcesses) is 0 then return
        set appProcess to item 1 of matchingProcesses

        tell appProcess
            set panelWindows to every window whose name is panelTitle
            if (count of panelWindows) is 0 then return
            set panelWindow to item 1 of panelWindows

            set parentWindow to missing value
            set largestArea to -1

            repeat with candidateWindow in every window
                try
                    if (name of candidateWindow) is not panelTitle then
                        set candidateSize to size of candidateWindow
                        set candidateArea to (item 1 of candidateSize) * (item 2 of candidateSize)
                        if candidateArea > largestArea then
                            set largestArea to candidateArea
                            set parentWindow to candidateWindow
                        end if
                    end if
                end try
            end repeat

            if parentWindow is missing value then return

            set panelSize to size of panelWindow
            set parentPosition to position of parentWindow
            set parentSize to size of parentWindow

            set centeredX to (item 1 of parentPosition) + (((item 1 of parentSize) - (item 1 of panelSize)) / 2)
            set centeredY to (item 2 of parentPosition) + (((item 2 of parentSize) - (item 2 of panelSize)) / 2)
            set position of panelWindow to {round centeredX, round centeredY}
        end tell
    end tell
end run
APPLESCRIPT
