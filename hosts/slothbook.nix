# Slothbook: personal Mac.
{...}: {
  imports = [../modules/personal.nix ../modules/desktop.nix ../modules/omniwm.nix ../modules/sketchybar.nix ../modules/menubar.nix];

  homebrew.casks = ["atoll" "discord" "steam" "roblox" "robloxstudio" "blender"];
}
