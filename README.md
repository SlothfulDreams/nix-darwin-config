# slothful nix-darwin

![NixOS logo](./assets/nixos.png)

[![nix-darwin](https://img.shields.io/badge/nix--darwin-macOS-7eb6dd?style=for-the-badge&logo=nixos&logoColor=white)](https://github.com/nix-darwin/nix-darwin)
[![Home Manager](https://img.shields.io/badge/home--manager-enabled-38bdf8?style=for-the-badge&logo=nixos&logoColor=white)](https://nix-community.github.io/home-manager/)
[![Nix flakes](https://img.shields.io/badge/flakes-on-14b8a6?style=for-the-badge&logo=nixos&logoColor=white)](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake)

## Snapshot

| Area | Current setup |
| --- | --- |
| Host | `Slothys-MacBook-Pro` |
| User | `slothy` |
| Platform | `aarch64-darwin` |
| Nixpkgs | `nixpkgs-unstable` |
| System layer | `nix-darwin` |
| Homebrew layer | `nix-homebrew` |
| User layer | Home Manager via `home.nix` |

## What This Manages

- System packages for shell work, JavaScript/mobile tooling, version control,
  editors, and creative tools.
- Homebrew casks for desktop apps like Helium, Ghostty, Raycast, Zed, Claude,
  Codex, Spotify, Vesktop, Docker Desktop, and 1Password.
- macOS defaults for dark mode, Dock contents, Dock autohide/magnification,
  Raycast hotkeys, Spotlight keybinding cleanup, and Caps Lock to Escape.
- Home Manager settings for Git, Zsh, Oh My Zsh, Ghostty config, `fzf`,
  `direnv`, `nix-direnv`, `zoxide`, and Codex Vim mode.
- A weekly launchd cleanup job that prunes old Nix generations and runs store
  garbage collection.

## Layout

```text
.
+-- flake.nix      # nix-darwin system, packages, Homebrew, macOS defaults
+-- home.nix       # Home Manager user config
+-- flake.lock     # pinned flake inputs
+-- assets/
|   +-- nixos.png  # local README banner
+-- README.md
```

## Daily Commands

Apply the system:

```sh
sudo darwin-rebuild switch --flake .#Slothys-MacBook-Pro
```

Or use the Home Manager Zsh alias from this repo root:

```sh
drs
```

Build without switching:

```sh
darwin-rebuild build --flake .#Slothys-MacBook-Pro
```

Update inputs:

```sh
nix flake update
```

Format Nix files:

```sh
nix fmt
```

## Package Buckets

| Bucket | Examples |
| --- | --- |
| Shell | `bat`, `eza`, `fd`, `fastfetch`, `fzf`, `ripgrep`, `tldr`, `television`, `tree`, `uv`, `zoxide` |
| Git | `git`, `gh` |
| Editors | `neovim` |
| JS/mobile | `bun`, `cocoapods`, `fnm`, `flutter`, `nodejs`, `pnpm`, `rustup`, `xcodegen` |
| Creative | `blender` |
| Apps | `helium-browser`, `ghostty`, `raycast`, `zed`, `claude`, `codex`, `1password`, `spotify`, `vesktop` |

## Notes

- `flake.nix` is the source of truth for system packages, Homebrew apps, fonts,
  macOS defaults, keyboard mapping, and nix-darwin modules.
- `home.nix` is the source of truth for user-level shell/editor behavior.
- Homebrew cleanup is set to `zap`, so removed casks are cleaned aggressively on
  activation.
- 1Password is configured to allow Helium through
  `/etc/1password/custom_allowed_browsers`.
- The Dock is intentionally short: Helium, Ghostty, Claude, and Codex.

## References

- [nix-darwin](https://github.com/nix-darwin/nix-darwin)
- [Nix flakes manual](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake)
- [Home Manager manual](https://nix-community.github.io/home-manager/)
