# Work Mac.
{username, ...}: {
  imports = [../modules/desktop.nix ../modules/aerospace.nix];

  # TODO: replace with the work git identity.
  home-manager.users.${username}.programs.git.settings.user = {
    name = "SlothfulDreams";
    email = "85036693+SlothfulDreams@users.noreply.github.com";
  };
}
