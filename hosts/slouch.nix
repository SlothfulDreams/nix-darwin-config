# Slouch: personal Mac Studio used as a cloud computer. No window manager, desktop
# apps or games (except Roblox Studio).
{...}: {
  imports = [../modules/personal.nix];

  homebrew.casks = ["robloxstudio" "blender" "claude"];
}
