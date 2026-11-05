# Slouch: personal Mac Studio used as a cloud computer. No window manager, desktop
# apps or games (except Roblox Studio).
{pkgs, ...}: {
  imports = [../modules/personal.nix];

  environment.systemPackages = [
    pkgs.deno # yt-dlp's default JavaScript runtime
  ];

  homebrew.casks = ["robloxstudio" "blender" "claude"];

  # imsg: iMessage/SMS CLI so agents can read and send Messages.
  homebrew.taps = ["steipete/tap"];
  homebrew.brews = ["steipete/tap/imsg"];
  nix-homebrew.trust.formulae = ["steipete/tap/imsg"];
}
