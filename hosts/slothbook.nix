# Slothbook: personal Mac.
{...}: {
  imports = [../modules/personal.nix ../modules/desktop.nix ../modules/aerospace.nix];

  homebrew.casks = ["discord" "steam" "roblox" "robloxstudio"];
}
