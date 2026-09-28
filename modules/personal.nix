# Shared by the personal Macs (Slothbook, Slouch): Tailscale and the Roblox
# dev tooling (selene, Rokit's bin dir, the ElevenLabs CLI for game audio).
{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = [pkgs.tailscale pkgs.selene];
  services.tailscale.enable = true;

  homebrew.taps = ["elevenlabs/tap"];
  homebrew.brews = ["elevenlabs/tap/elevenlabs"];

  home-manager.users.${username}.home.sessionPath = ["$HOME/.rokit/bin"];
}
