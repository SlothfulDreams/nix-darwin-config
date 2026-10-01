# AeroSpace tiling window manager: the Homebrew cask, a launchd agent that
# starts it, and its config. Imported by the hosts that use it.
{username, ...}: {
  homebrew.taps = ["nikitabobko/tap"];
  homebrew.casks = ["nikitabobko/tap/aerospace"];

  # Launch AeroSpace in the primary user's GUI session.
  launchd.user.agents.aerospace.serviceConfig = {
    ProgramArguments = [
      "/Applications/AeroSpace.app/Contents/MacOS/AeroSpace"
    ];
    RunAtLoad = true;
    ProcessType = "Interactive";
  };

  # Keybindings and layout, deployed by Home Manager (start-at-login is forced
  # false by its module, so it doesn't conflict with the agent above).
  # center-panel.sh is referenced by its Nix store path directly.
  home-manager.users.${username}.programs.aerospace = {
    enable = true;
    package = null;
    settings = {
      config-version = 2;
      auto-reload-config = true;

      # Keep the tree predictable as windows are moved and closed.
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      # Tile new workspaces automatically; orientation follows monitor shape.
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";
      accordion-padding = 30;

      # 1 Development, 2 Research, 3 Chat, 4 Spotify, 5-7 Spare. Workspaces
      # aren't pinned to monitors: summon one to the focused monitor and
      # switching to it later focuses whichever monitor it is on.
      persistent-workspaces = ["1" "2" "3" "4" "5" "6" "7"];
      focus-follows-mouse.enabled = false;
      automatically-unhide-macos-hidden-apps = false;

      # Lazy mouse warp to the newly focused monitor.
      on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

      # Edge-to-edge tiling, no gaps.
      gaps = {
        inner.horizontal = 0;
        inner.vertical = 0;
        outer = {
          left = 0;
          bottom = 0;
          top = 0;
          right = 0;
        };
      };

      mode.main.binding = {
        # Layouts
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";
        alt-f = "fullscreen";
        alt-shift-space = "layout floating tiling";

        # Launch or activate Ghostty; use Raycast for other applications.
        alt-enter = "exec-and-forget open -a 'Ghostty'";

        # Focus windows
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        # Move windows
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        # Focus monitors with the same Vim directions plus Control.
        alt-ctrl-h = "focus-monitor --wrap-around left";
        alt-ctrl-j = "focus-monitor --wrap-around down";
        alt-ctrl-k = "focus-monitor --wrap-around up";
        alt-ctrl-l = "focus-monitor --wrap-around right";

        # Add Shift to move the focused window to that monitor and follow it.
        alt-ctrl-shift-h = "move-node-to-monitor --focus-follows-window --wrap-around left";
        alt-ctrl-shift-j = "move-node-to-monitor --focus-follows-window --wrap-around down";
        alt-ctrl-shift-k = "move-node-to-monitor --focus-follows-window --wrap-around up";
        alt-ctrl-shift-l = "move-node-to-monitor --focus-follows-window --wrap-around right";

        # Resize windows
        alt-minus = "resize smart -50";
        alt-equal = "resize smart +50";
        alt-r = "mode resize";
        alt-g = "mode join";

        # Switch workspaces; same key again returns to the previous one.
        alt-1 = "workspace --auto-back-and-forth 1";
        alt-2 = "workspace --auto-back-and-forth 2";
        alt-3 = "workspace --auto-back-and-forth 3";
        alt-4 = "workspace --auto-back-and-forth 4";
        alt-5 = "workspace --auto-back-and-forth 5";
        alt-6 = "workspace --auto-back-and-forth 6";
        alt-7 = "workspace --auto-back-and-forth 7";

        # Move the focused window between workspaces.
        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";

        # Bring a workspace to the focused monitor.
        alt-ctrl-1 = "summon-workspace 1";
        alt-ctrl-2 = "summon-workspace 2";
        alt-ctrl-3 = "summon-workspace 3";
        alt-ctrl-4 = "summon-workspace 4";
        alt-ctrl-5 = "summon-workspace 5";
        alt-ctrl-6 = "summon-workspace 6";
        alt-ctrl-7 = "summon-workspace 7";

        alt-tab = "workspace-back-and-forth";
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
        alt-shift-semicolon = "mode service";
      };

      # Resize mode: Alt+R, then H/J/K/L. Escape or Enter returns to main.
      mode.resize.binding = {
        h = "resize width -50";
        j = "resize height +50";
        k = "resize height -50";
        l = "resize width +50";
        esc = "mode main";
        enter = "mode main";
      };

      # Join mode: Alt+G, then H/J/K/L to join in that direction.
      mode.join.binding = {
        h = ["join-with left" "mode main"];
        j = ["join-with down" "mode main"];
        k = ["join-with up" "mode main"];
        l = ["join-with right" "mode main"];
        esc = "mode main";
        enter = "mode main";
      };

      # Service mode: Alt+Shift+; followed by one of these keys.
      mode.service.binding = {
        esc = ["reload-config" "mode main"];
        r = ["flatten-workspace-tree" "mode main"];
        b = ["balance-sizes" "mode main"];
        backspace = ["close-all-windows-but-current" "mode main"];
      };

      # Route primary applications to role-based workspaces. Browser callbacks
      # keep processing so the picture-in-picture rules below can also float.
      on-window-detected = [
        {
          "if" = "test %{app-bundle-id} = com.mitchellh.ghostty";
          run = "move-node-to-workspace 1";
          check-further-callbacks = true;
        }
        {
          "if" = "test %{app-bundle-id} = com.anthropic.claudefordesktop || test %{app-bundle-id} = com.openai.codex";
          run = "move-node-to-workspace 2";
          check-further-callbacks = true;
        }
        {
          "if" = "test %{app-bundle-id} = net.imput.helium || test %{app-bundle-id} = com.google.Chrome";
          run = "move-node-to-workspace 2";
          check-further-callbacks = true;
        }
        {
          "if" = "test %{app-bundle-id} = com.hnc.Discord || test %{app-bundle-id} = com.tinyspeck.slackmacgap";
          run = "move-node-to-workspace 3";
          check-further-callbacks = true;
        }
        {
          "if" = "test %{app-bundle-id} = dev.zed.Zed";
          run = "move-node-to-workspace 1";
          check-further-callbacks = true;
        }
        {
          "if" = "test %{app-bundle-id} = com.spotify.client";
          run = "move-node-to-workspace 4";
          check-further-callbacks = true;
        }

        # Float standalone preference panels while leaving regular app windows
        # tiled. Browsers excluded: their Settings pages are ordinary tabs.
        {
          "if" = "test %{window-title} ~= \"^(Preferences|Settings)$\" && test-not %{app-bundle-id} = net.imput.helium && test-not %{app-bundle-id} = com.google.Chrome && test-not %{app-bundle-id} = com.apple.Safari";
          run = [
            "layout floating"
            "exec-and-forget ${../aerospace/center-panel.sh} %{app-bundle-id} %{window-title}"
          ];
        }

        # Keep small Apple apps out of the tiling tree.
        {
          "if" = "test %{app-bundle-id} = com.apple.finder || test %{app-bundle-id} = com.apple.systempreferences || test %{app-bundle-id} = com.apple.calculator || test %{app-bundle-id} = com.apple.FaceTime || test %{app-bundle-id} = com.apple.MobileSMS";
          run = "layout floating";
        }

        # System utilities work better as free-sized panels than as tiles.
        {
          "if" = "test %{app-bundle-id} = com.apple.ActivityMonitor || test %{app-bundle-id} = com.apple.airport.airportutility || test %{app-bundle-id} = com.apple.audio.AudioMIDISetup || test %{app-bundle-id} = com.apple.BluetoothFileExchange || test %{app-bundle-id} = com.apple.ColorSyncUtility || test %{app-bundle-id} = com.apple.DigitalColorMeter || test %{app-bundle-id} = com.apple.DiskUtility || test %{app-bundle-id} = com.apple.printcenter || test %{app-bundle-id} = com.apple.SystemProfiler || test %{app-bundle-id} = com.apple.VoiceOverUtility";
          run = "layout floating";
        }

        # Third-party control panels and menu-bar utilities.
        {
          "if" = "test %{app-bundle-id} = com.1password.1password || test %{app-bundle-id} = com.docker.docker || test %{app-bundle-id} = com.logi.optionsplus || test %{app-bundle-id} = com.raycast.macos || test %{app-bundle-id} = com.electron.wispr-flow || test %{app-bundle-id} = com.workpuls.Agent";
          run = "layout floating";
        }

        # Float only browser windows whose titles identify picture-in-picture.
        {
          "if" = "test %{app-bundle-id} = net.imput.helium && test %{window-title} ~= \"picture.?in.?picture\"";
          run = "layout floating";
        }
        {
          "if" = "test %{app-bundle-id} = com.google.Chrome && test %{window-title} ~= \"picture.?in.?picture\"";
          run = "layout floating";
        }
      ];
    };
  };
}
