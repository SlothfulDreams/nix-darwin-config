# slothful nix-darwin

![NixOS logo](./assets/nixos.png)

[![nix-darwin](https://img.shields.io/badge/nix--darwin-macOS-7eb6dd?style=for-the-badge&logo=nixos&logoColor=white)](https://github.com/nix-darwin/nix-darwin)
[![Home Manager](https://img.shields.io/badge/home--manager-enabled-38bdf8?style=for-the-badge&logo=nixos&logoColor=white)](https://nix-community.github.io/home-manager/)
[![Nix flakes](https://img.shields.io/badge/flakes-on-14b8a6?style=for-the-badge&logo=nixos&logoColor=white)](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake)

## Snapshot

| Area | Current setup |
| --- | --- |
| Config | `default` (works on any Mac, regardless of hostname) |
| User | `slothy` |
| Platform | `aarch64-darwin` |
| Nixpkgs | `nixpkgs-unstable` |
| System layer | `nix-darwin` |
| Homebrew layer | `nix-homebrew` |
| User layer | Home Manager via `home.nix` |

## Fresh Mac Setup

One generic `default` configuration works on every Apple Silicon Mac with the
`slothy` user, no matter the hostname. From a brand-new machine:

### 1. Install Nix

Use the [official installer](https://nixos.org/download/) (multi-user, the
only supported mode on macOS):

```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
```

Then open a new shell so `nix` is on your `PATH`.

> Don't use the Determinate installer: it now installs Determinate Nix, which
> requires `nix.enable = false` in nix-darwin and conflicts with the `nix.*`
> settings this flake manages.

### 2. Apply this flake (one command)

Straight from GitHub, no clone needed:

```sh
sudo nix run --extra-experimental-features "nix-command flakes" nix-darwin/master#darwin-rebuild -- switch --flake github:SlothfulDreams/nix-darwin-config#default
```

The `--extra-experimental-features` flag is only needed this first time; the
flake enables flakes permanently from then on.

This installs nix-darwin, Homebrew (via nix-homebrew), all packages, casks,
macOS defaults, and the Home Manager user config in a single pass.

> Note: Nix itself doesn't need Xcode Command Line Tools, but Homebrew may
> prompt for them (`xcode-select --install`) if a tap formula has to build
> from source.

### 3. (Optional) Clone for local edits

```sh
git clone https://github.com/SlothfulDreams/nix-darwin-config.git ~/.config/nix
```

After the first activation, `darwin-rebuild` is on your `PATH` and the `drs` /
`nup` shell helpers are available, so future rebuilds are just `drs` from
`~/.config/nix`.

## What This Manages

- System packages for shell work, networking, JavaScript/mobile tooling,
  version control, editors, and creative tools.
- System services for Tailscale.
- Homebrew casks for desktop apps like Docker Desktop, Helium, 1Password,
  Obsidian, Raycast, Discord, Slack, Spotify, Steam, Roblox Studio, Ghostty, Zed,
  Visual Studio Code, Claude, Claude Code, ChatGPT, Wispr Flow, and
  OpenLogi.
- macOS defaults for dark mode, Dock contents, Dock autohide/magnification,
  Raycast hotkeys, Spotlight keybinding cleanup, and Caps Lock to Escape.
- Home Manager settings for Git, Zsh, Oh My Zsh, Ghostty config, `fzf`,
  `direnv`, `nix-direnv`, `zoxide`, and Codex Vim mode.
- A weekly launchd cleanup job that keeps the last 5 Nix generations and runs
  store garbage collection.

## Layout

```text
.
+-- flake.nix      # nix-darwin system, packages, services, Homebrew, macOS defaults
+-- home.nix       # Home Manager user config
+-- flake.lock     # pinned flake inputs
+-- assets/
|   +-- nixos.png  # local README banner
+-- README.md
```

## Daily Commands

Apply the system:

```sh
sudo darwin-rebuild switch --flake .#default
```

Or use the Home Manager Zsh function from this repo root. It keeps sudo authorization active for the full rebuild, including Homebrew operations:

```sh
drs
```

Build without switching:

```sh
darwin-rebuild build --flake .#default
```

Update all inputs and rebuild in one go:

```sh
nup
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
| Shell | `bat`, `eza`, `fd`, `fastfetch`, `fzf`, `herdr`, `ripgrep`, `tldr`, `television`, `tree`, `uv`, `zoxide` |
| Git | `git`, `gh` |
| Networking | `tailscale` |
| Media | `ffmpeg` |
| Editors | `neovim`, `selene` |
| JS/mobile | `bun`, `cocoapods`, `fnm`, `flutter`, `nodejs`, `pnpm`, `rustup`, `xcodegen` |
| Creative | `blender` |
| Apps | `docker-desktop`, `helium-browser`, `1password`, `obsidian`, `raycast`, `discord`, `slack`, `spotify`, `steam`, `robloxstudio`, `ghostty`, `zed`, `visual-studio-code`, `claude`, `claude-code@latest`, `chatgpt`, `wispr-flow` |

## Services

| Service | Status |
| --- | --- |
| Tailscale | Enabled at startup |

## Notes

- `flake.nix` is the source of truth for system packages, Homebrew apps, fonts,
  macOS defaults, keyboard mapping, and nix-darwin modules.
- `home.nix` is the source of truth for user-level shell/editor behavior.
- Homebrew cleanup is set to `zap`, so removed casks are cleaned aggressively on
  activation.
- 1Password is configured to allow Helium through
  `/etc/1password/custom_allowed_browsers`.
- The Dock is intentionally short: Helium, Ghostty, Claude, and ChatGPT.

## References

- [nix-darwin](https://github.com/nix-darwin/nix-darwin)
- [Nix flakes manual](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake)
- [Home Manager manual](https://nix-community.github.io/home-manager/)
