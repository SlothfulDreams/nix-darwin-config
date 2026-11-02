# OmniWM tiling window manager: Home Manager installs it and runs it as a
# launchd agent.
{
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username}.programs.omniwm = {
    enable = true;
    # Hotkeys, gaps sized for SketchyBar, app rules and which workspace each
    # app opens on. Home Manager re-links this file on every switch, so a
    # change made in OmniWM's Settings window only sticks if it is copied back
    # here (`cp ~/.config/omniwm/settings.toml omniwm/`).
    settings = ../omniwm/settings.toml;
  };

  # Free ctrl+opt+space (input source switching) for OmniWM's command palette.
  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys."61".enabled = false;

  # Make per-app workspace rules apply to every new window, not just the
  # app's first one (see ../omniwm/assign-workspaces.sh). Needs IPC enabled.
  launchd.user.agents.omniwm-assign-workspaces = {
    path = [pkgs.omniwm pkgs.jq];
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.omniwm}/bin/omniwmctl"
        "watch"
        "windows-changed"
        "--no-send-initial"
        "--reconnect"
        "--exec"
        "${pkgs.bash}/bin/bash"
        "${../omniwm/assign-workspaces.sh}"
      ];
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
