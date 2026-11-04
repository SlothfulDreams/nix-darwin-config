# OmniWM tiling window manager: Home Manager installs it and runs it as a
# launchd agent.
{username, ...}: {
  home-manager.users.${username}.programs.omniwm = {
    enable = true;
    # Hotkeys, gaps sized for SketchyBar and app rules. Home Manager re-links
    # this file on every switch, so a change made in OmniWM's Settings window
    # only sticks if it is copied back here
    # (`cp ~/.config/omniwm/settings.toml omniwm/`).
    settings = ../omniwm/settings.toml;
  };

  # Free ctrl+opt+space (input source switching) for OmniWM's command palette.
  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys."61".enabled = false;
}
