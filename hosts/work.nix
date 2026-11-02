# Work Mac.
{username, ...}: {
  imports = [../modules/desktop.nix ../modules/omniwm.nix ../modules/sketchybar.nix ../modules/menubar.nix];

  # TODO: replace with the work git identity.
  home-manager.users.${username}.programs.git.settings.user = {
    name = "SlothfulDreams";
    email = "85036693+SlothfulDreams@users.noreply.github.com";
  };
}
