# SketchyBar status bar (config in ../sketchybar). OmniWM pushes workspace
# changes to it over IPC (needs `ipcEnabled = true` in
# ~/.config/omniwm/settings.toml). See ./menubar.nix for hiding macOS's own bar.
{
  config,
  pkgs,
  ...
}: let
  # Hides SketchyBar while macOS's menu bar is showing, so they never overlap.
  sketchybar-menubar = pkgs.runCommandCC "sketchybar-menubar" {} ''
    mkdir -p $out/bin
    $CC -O2 -Wall -Wextra -framework ApplicationServices -o $out/bin/sketchybar-menubar ${../sketchybar/menubar.c}
  '';
in {
  services.sketchybar = {
    enable = true;
    extraPackages = [pkgs.jq pkgs.omniwm];
    config = ''
      CONFIG_DIR=${../sketchybar}
      source "$CONFIG_DIR/sketchybarrc"
    '';
  };

  # Re-render the workspace pills whenever OmniWM's own bar would: workspace
  # switches, focus changes and windows opening, closing or moving.
  launchd.user.agents.sketchybar-omniwm.serviceConfig = {
    ProgramArguments = [
      "${pkgs.omniwm}/bin/omniwmctl"
      "watch"
      "workspace-bar"
      "--no-send-initial"
      "--reconnect"
      "--exec"
      "${config.services.sketchybar.package}/bin/sketchybar"
      "--trigger"
      "omniwm_update"
    ];
    RunAtLoad = true;
    KeepAlive = true;
  };

  # Step aside for the real menu bar whenever it slides down.
  launchd.user.agents.sketchybar-menubar = {
    path = [config.services.sketchybar.package];
    serviceConfig = {
      ProgramArguments = ["${sketchybar-menubar}/bin/sketchybar-menubar"];
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
