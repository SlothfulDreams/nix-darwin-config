# Shared by the personal Macs (Slothbook, Slouch): Tailscale and the Roblox
# dev tooling (selene, Rokit's bin dir, the ElevenLabs CLI for game audio).
{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = [pkgs.tailscale pkgs.selene];
  services.tailscale.enable = true;

  homebrew.taps = ["elevenlabs/tap" "openai/tools"];
  homebrew.brews = ["elevenlabs/tap/elevenlabs" "openai/tools/tart"];
  # softnet is a tart dependency; brew refuses to load it unless trusted too.
  nix-homebrew.trust.formulae = ["elevenlabs/tap/elevenlabs" "openai/tools/tart" "openai/tools/softnet"];

  home-manager.users.${username}.home.sessionPath = ["$HOME/.rokit/bin"];
}
