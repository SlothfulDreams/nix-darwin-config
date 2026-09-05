{
  pkgs,
  lib,
  ...
}: {
  home.stateVersion = "26.05";

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.rokit/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PI_FFF_MODE = "override";
  };

  home.file.".hushlogin".text = "";

  # Ensure home-manager-managed configs (including AeroSpace) land under
  # ~/.config rather than dotfiles in $HOME.
  xdg.enable = true;

  # AeroSpace window manager. The app is installed via the Homebrew cask and
  # launched by a launchd agent in flake.nix (start-at-login is forced false
  # by this module, so they don't conflict). center-panel.sh is referenced by
  # its Nix store path directly.
  programs.aerospace = {
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

      # Main monitor: 1 Development, 2 Research, 3 Chat, 4 Spotify.
      # Secondary monitor: 5-7 Spare (see force-assignment below).
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

      # Pin workspaces to monitors (i3-style). 5-7 fall back to main when
      # only one screen is present.
      workspace-to-monitor-force-assignment = {
        "1" = "main";
        "2" = "main";
        "3" = "main";
        "4" = "main";
        "5" = ["secondary" "main"];
        "6" = ["secondary" "main"];
        "7" = ["secondary" "main"];
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
            "exec-and-forget ${./aerospace/center-panel.sh} %{app-bundle-id} %{window-title}"
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

  # Ghostty terminal config. Ghostty itself is installed via the homebrew cask
  # in flake.nix; package = null because nixpkgs ghostty is the Linux build and
  # is unavailable on macOS. This only writes ~/.config/ghostty/config.
  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      font-size = 18;
      copy-on-select = "clipboard";
      shell-integration-features = "ssh-env,ssh-terminfo";
    };
  };

  # Herdr is installed through Homebrew in flake.nix. Home Manager owns its
  # configuration without installing a second copy from nixpkgs.
  programs.herdr = {
    enable = true;
    package = null;
    settings = {
      onboarding = false;

      terminal.new_cwd = "follow";

      ui = {
        show_agent_labels_on_pane_borders = true;
        toast.delivery = "herdr";
      };

      keys = {
        # Herdr keymap: direct Vim-style movement plus prefixed actions.
        prefix = "ctrl+a";

        open_worktree = "prefix+f";
        remove_worktree = "prefix+d";

        focus_pane_left = "ctrl+h";
        focus_pane_down = "ctrl+j";
        focus_pane_up = "ctrl+k";
        focus_pane_right = "ctrl+l";

        previous_workspace = "prefix+h";
        next_workspace = "prefix+l";
        previous_agent = "prefix+k";
        next_agent = "prefix+j";

        switch_workspace = "prefix+shift+1..9";
        focus_agent = "prefix+alt+1..9";

        command = [
          {
            key = "cmd+r";
            type = "plugin_action";
            command = "persiyanov.reviewr.toggle";
          }
        ];
      };

      experimental = {
        pane_history = false;
        kitty_graphics = true;
      };
    };
  };

  home.activation.setCodexVimMode = lib.hm.dag.entryAfter ["writeBoundary"] ''
    config="$HOME/.codex/config.toml"
    mkdir -p "$(dirname "$config")"

    if [ ! -f "$config" ]; then
      printf '[tui]\nvim_mode_default = true\n' > "$config"
    elif grep -q '^[[:space:]]*vim_mode_default[[:space:]]*=' "$config"; then
      ${pkgs.perl}/bin/perl -0pi -e 's/^[ \t]*vim_mode_default[ \t]*=.*$/vim_mode_default = true/m' "$config"
    elif grep -q '^[[:space:]]*\[tui\][[:space:]]*$' "$config"; then
      ${pkgs.perl}/bin/perl -0pi -e 's/^(\[tui\][^\n]*\n)/$1vim_mode_default = true\n/m' "$config"
    else
      printf '\n[tui]\nvim_mode_default = true\n' >> "$config"
    fi
  '';

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      user = {
        name = "SlothfulDreams";
        email = "85036693+SlothfulDreams@users.noreply.github.com";
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = ["git" "colored-man-pages" "copypath" "copyfile"];
    };

    shellAliases = {
      nup = "sudo sh -c \"cd $HOME/.config/nix && nix flake update && darwin-rebuild switch --flake .#default\"";
    };

    initContent = ''
      eval "$(${pkgs.fnm}/bin/fnm env --use-on-cd --shell zsh)"

      drs() {
        sudo -v || return
        (
          while sudo -n true 2>/dev/null; do
            sleep 50
          done
        ) &
        local sudo_keepalive_pid=$!

        sudo darwin-rebuild switch --flake .#default
        local rc=$?

        kill "$sudo_keepalive_pid" 2>/dev/null
        wait "$sudo_keepalive_pid" 2>/dev/null
        return "$rc"
      }
    '';
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = ["--group-directories-first"];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };
}
