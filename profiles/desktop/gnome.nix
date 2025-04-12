# profiles/desktop/gnome.nix
#
# A complete GNOME desktop environment profile
{
  configLib,
  ...
}:
{
  imports = [
    # Import the minimal core profile
    (configLib.profileImport "core/minimal.nix")
    (configLib.moduleImport "hardware/hw-secureboot.nix")

    # Desktop environment
    (configLib.moduleImport "desktop/desktop-gnome.nix")
    (configLib.moduleImport "desktop/desktop-fonts.nix")
    (configLib.moduleImport "desktop/desktop-stylix.nix")

    # Common desktop services
    (configLib.moduleImport "services/audio.nix")

    # Applications
    (configLib.moduleImport "applications/app-1password.nix")
    (configLib.moduleImport "applications/app-claude.nix")
    (configLib.moduleImport "applications/app-discord.nix")
    (configLib.moduleImport "applications/app-firefox.nix")
    (configLib.moduleImport "applications/app-gaming.nix")
    (configLib.moduleImport "applications/app-remmina.nix")
    (configLib.moduleImport "applications/app-zed.nix")
  ];
}
