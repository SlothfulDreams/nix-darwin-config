# OmniWM tiling window manager: Home Manager installs it and runs it as a
# launchd agent. Hosts may pin settings.toml via programs.omniwm.settings
# (slothbook does); otherwise it is edited from OmniWM's Settings window.
{
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username}.programs.omniwm.enable = true;

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
