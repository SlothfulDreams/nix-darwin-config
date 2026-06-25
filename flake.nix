{
  description = "slothful nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nix-homebrew,
    home-manager,
  }: let
    configuration = {pkgs, ...}: {
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

        # Networking
        pkgs.tailscale

        # Editors and terminals
        pkgs.neovim

        # JavaScript tooling
        pkgs.bun
        pkgs.cocoapods
        pkgs.fnm
        pkgs.flutter
        pkgs.nodejs
        pkgs.pnpm
        pkgs.rustup
        pkgs.xcodegen

        # Creative tools
        pkgs.blender
      ];

      # ---- Homebrew ----------------------------------------------------------
      homebrew = {
        enable = true;
        brews = [
          "mole"
        ];
        casks = [
          "docker-desktop"
          "helium-browser"
          "1password"
          "raycast"
          "vesktop"
          "spotify"
          "steam"
          "ghostty"
          "zed"
          "visual-studio-code"
          "claude"
          "claude-code"
          "codex"
          "codex-app"
          "wispr-flow"
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

      # ---- App Configuration -------------------------------------------------
      environment.etc."1password/custom_allowed_browsers".text = ''
        net.imput.helium
      '';

      system.primaryUser = "slothy";
      users.users.slothy.home = "/Users/slothy";

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
            "/Applications/Codex.app"
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
        sudo -u slothy /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';

      # ---- Garbage Collection ------------------------------------------------
      launchd.daemons.nix-generation-cleanup = {
        script = ''
          set -eu

          keep_generations() {
            profile="$1"
            if [ -e "$profile" ]; then
              ${pkgs.nix}/bin/nix-env --profile "$profile" --delete-generations +14
            fi
          }

          keep_generations /nix/var/nix/profiles/system
          keep_generations /nix/var/nix/profiles/per-user/root/profile
          keep_generations /nix/var/nix/profiles/per-user/slothy/profile
          keep_generations /nix/var/nix/profiles/per-user/slothy/home-manager
          keep_generations /Users/slothy/.local/state/nix/profiles/profile
          keep_generations /Users/slothy/.local/state/nix/profiles/home-manager

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
    };
  in {
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Slothys-MacBook-Pro
    darwinConfigurations."Slothys-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager
        {
          nix-homebrew = {
            enable = true;
            user = "slothy";
          };

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.slothy = import ./home.nix;
          };
        }
      ];
    };
  };
}
