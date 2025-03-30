# profiles/desktop/gnome.nix
#
# A complete GNOME desktop environment profile
{
  configLib,
  ...
}: {
  imports = [
    # Import the minimal core profile
    (configLib.profileImport "core/minimal.nix")

    # Desktop environment
    (configLib.moduleImport "desktop/environments/gnome.nix")
    (configLib.moduleImport "desktop/fonts.nix")
    (configLib.moduleImport "desktop/theme/stylix.nix")
    
    # Common desktop services
    (configLib.moduleImport "services/audio.nix")
    
    # Common applications
    (configLib.profileImport "applications/browser.nix")
  ];
}