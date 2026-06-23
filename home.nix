{
  pkgs,
  lib,
  ...
}: {
  home.stateVersion = "26.05";

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.file.".hushlogin".text = "";

  # Ghostty terminal config. Ghostty itself is installed via the homebrew cask
  # in flake.nix; package = null because nixpkgs ghostty is the Linux build and
  # is unavailable on macOS. This only writes ~/.config/ghostty/config.
  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      font-size = 18;
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
      plugins = ["git"];
    };

    shellAliases = {
      drs = "sudo darwin-rebuild switch --flake .";
    };

    initContent = ''
      eval "$(${pkgs.fnm}/bin/fnm env --use-on-cd --shell zsh)"
    '';
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
