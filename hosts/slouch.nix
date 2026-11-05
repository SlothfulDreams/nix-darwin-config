# Slouch: personal Mac Studio used as a cloud computer. No window manager, desktop
# apps or games (except Roblox Studio).
{pkgs, ...}: {
  imports = [../modules/personal.nix];

  environment.systemPackages = [
    pkgs.deno # yt-dlp's default JavaScript runtime
  ];

  homebrew.casks = ["robloxstudio" "blender" "claude"];
}
