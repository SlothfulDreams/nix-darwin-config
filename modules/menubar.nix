# Auto-hide macOS's own menu bar so SketchyBar can take its place. It still
# slides down when the pointer reaches the top edge; sketchybar-menubar in
# ./sketchybar.nix hides SketchyBar while it is showing.
{
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
}
