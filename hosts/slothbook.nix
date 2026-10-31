# Slothbook: personal Mac.
{username, ...}: {
  imports = [../modules/personal.nix ../modules/desktop.nix ../modules/omniwm.nix ../modules/sketchybar.nix ../modules/menubar.nix];

  homebrew.casks = ["atoll" "discord" "steam" "roblox" "robloxstudio" "blender"];

  # OmniWM settings: hotkeys, gaps sized for SketchyBar, app rules and which
  # workspace each app opens on. Home Manager re-links this file on every
  # switch, so a change made in OmniWM's Settings window only sticks if it is
  # copied back here (`cp ~/.config/omniwm/settings.toml omniwm/`).
  home-manager.users.${username}.programs.omniwm.settings = ../omniwm/settings.toml;
}
