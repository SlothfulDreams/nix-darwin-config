# Slouch: personal Mac Studio used as a cloud computer. No AeroSpace, desktop
# apps or games (except Roblox Studio).
{...}: {
  imports = [../modules/personal.nix];

  homebrew.casks = ["robloxstudio" "blender" "claude"];
}
