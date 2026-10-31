# OmniWM tiling window manager: Home Manager installs it and runs it as a
# launchd agent. Hosts may pin settings.toml via programs.omniwm.settings
# (slothbook does); otherwise it is edited from OmniWM's Settings window.
{username, ...}: {
  home-manager.users.${username}.programs.omniwm.enable = true;

  # Free ctrl+opt+space (input source switching) for OmniWM's command palette.
  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys."61".enabled = false;
}
