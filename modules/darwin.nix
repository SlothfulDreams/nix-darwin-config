# Shared nix-darwin config applied to every host. Host-specific tweaks live in
# ../hosts/<host>.nix.
{
  pkgs,
  self,
  username,
  ...
}: let
  homeDir = "/Users/${username}";
in {
  # ---- Nixpkgs ------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;

  # ---- Packages ----------------------------------------------------------
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    # Shell utilities
    pkgs.bat
    pkgs.eza
    pkgs.fd
    pkgs.fastfetch
    pkgs.fzf
    pkgs.ripgrep
    pkgs.tldr
    pkgs.television
    pkgs.tree
    pkgs.uv
    pkgs.zoxide

    # Version control
    pkgs.git
    pkgs.gh

    # Media tools
    pkgs.ffmpeg
    pkgs.yt-dlp

    # Editors and terminals
    pkgs.neovim

    # JavaScript tooling
    pkgs.bun
    pkgs.cocoapods
    pkgs.fnm
    pkgs.nodejs
    pkgs.pnpm
    pkgs.rustup
    pkgs.xcodegen
  ];

  # ---- Homebrew ----------------------------------------------------------
  homebrew = {
    enable = true;
    taps = [
      "greptileai/tap"
    ];
    brews = [
      "mole"
      "herdr"
      "pi-coding-agent"
      "greptileai/tap/greptile"
    ];
    casks = [
      "docker-desktop"
      "helium-browser"
      "1password"
      "obsidian"
      "raycast"
      "slack"
      "ghostty"
      "claude-code@latest"
      "chatgpt"
      "codex"
      "cursor-cli"
      "openlogi"
    ];

    masApps = {};

    # Brew Activation
    onActivation = {
      cleanup = "zap";
      upgrade = true;
      autoUpdate = true;
    };
  };

  # ---- Fonts -------------------------------------------------------------
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # ---- Services ----------------------------------------------------------
  services = {
    openssh.enable = true;
  };

  # ---- App Configuration -------------------------------------------------
  environment.etc."1password/custom_allowed_browsers".text = ''
    net.imput.helium
  '';

  system.primaryUser = username;
  users.users.${username}.home = homeDir;

  system.defaults = {
    CustomUserPreferences = {
      "com.raycast.macos" = {
        raycastGlobalHotkey = "Command-49";
        commandAliases = {
          windowManagementToggleFullscreen = "fs";
          windowManagementMaximize = "mx";
          windowManagementLeftHalf = "lh";
          windowManagementRightHalf = "rh";
        };
      };
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          "60".enabled = false; # disable ctrl+space input source switching
          "64".enabled = false; # disable cmd+space for Spotlight Search
        };
      };
    };

    # ---- macOS Defaults --------------------------------------------------
    NSGlobalDomain = {
      AppleIconAppearanceTheme = "RegularDark";
      AppleInterfaceStyle = "Dark";
    };
    dock = {
      autohide = true;
      largesize = 128;
      magnification = true;
      persistent-apps = [
        "/Applications/Helium.app"
        "/Applications/Ghostty.app"
        "/Applications/Claude.app"
        "/Applications/ChatGPT.app"
      ];
      persistent-others = [];
    };
  };

  # ---- Keyboard ----------------------------------------------------------
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # ---- Shell -------------------------------------------------------------
  programs.zsh.enable = true;

  # ---- Activation --------------------------------------------------------
  # Make macOS apply nix-darwin's user defaults in the current GUI session.
  # Without this, settings may be written but not visible until logout/restart.
  system.activationScripts.postActivation.text = ''
    echo >&2 "activating user defaults..."
    sudo -u ${username} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  # ---- Garbage Collection ------------------------------------------------
  launchd.daemons.nix-generation-cleanup = {
    script = ''
      set -eu

      keep_generations() {
        profile="$1"
        if [ -e "$profile" ]; then
          ${pkgs.nix}/bin/nix-env --profile "$profile" --delete-generations +5
        fi
      }

      keep_generations /nix/var/nix/profiles/system
      keep_generations /nix/var/nix/profiles/per-user/root/profile
      keep_generations /nix/var/nix/profiles/per-user/${username}/profile
      keep_generations /nix/var/nix/profiles/per-user/${username}/home-manager
      keep_generations ${homeDir}/.local/state/nix/profiles/profile
      keep_generations ${homeDir}/.local/state/nix/profiles/home-manager

      ${pkgs.nix}/bin/nix-store --gc
    '';
    serviceConfig = {
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 3;
          Minute = 30;
        }
      ];
      StandardOutPath = "/var/log/nix-generation-cleanup.log";
      StandardErrorPath = "/var/log/nix-generation-cleanup.log";
    };
  };

  # ---- Nix ---------------------------------------------------------------
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # ---- System Metadata ---------------------------------------------------
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
