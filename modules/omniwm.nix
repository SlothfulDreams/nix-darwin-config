# OmniWM tiling window manager: Home Manager installs it and runs it as a
# launchd agent. settings.toml is left unmanaged so it can be edited from
# OmniWM's Settings window; move it into `settings` here once it's settled.
{username, ...}: {
  home-manager.users.${username}.programs.omniwm.enable = true;

  # Free ctrl+opt+space (input source switching) for OmniWM's command palette.
  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys."61".enabled = false;
}
