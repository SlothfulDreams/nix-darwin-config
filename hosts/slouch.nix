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
  # whisper-cpp: local speech-to-text; HyperFrames (`hyperframes transcribe`) uses it
  # and brew-installs it on its own if missing, so keep it listed or a switch zaps it.
  homebrew.brews = ["steipete/tap/imsg" "whisper-cpp"];
  nix-homebrew.trust.formulae = ["steipete/tap/imsg"];
}
