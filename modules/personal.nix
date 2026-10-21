# Shared by the personal Macs (Slothbook, Slouch): Tailscale and the Roblox
# dev tooling (selene, Rokit's bin dir, the ElevenLabs CLI for game audio),
# plus Ghidra.
{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = [pkgs.tailscale pkgs.selene pkgs.ghidra];
  services.tailscale.enable = true;
  # nix-darwin symlinks this into /etc/static, but tailscaled (1.104+) writes it
  # via os.Root and rejects the out-of-tree symlink ("path escapes from parent").
  environment.etc."resolver/ts.net".enable = false;

  homebrew.taps = ["elevenlabs/tap" "openai/tools"];
  homebrew.brews = ["elevenlabs/tap/elevenlabs" "openai/tools/tart"];
  # softnet is a tart dependency; brew refuses to load it unless trusted too.
  nix-homebrew.trust.formulae = ["elevenlabs/tap/elevenlabs" "openai/tools/tart" "openai/tools/softnet"];

  home-manager.users.${username}.home.sessionPath = ["$HOME/.rokit/bin"];
}
