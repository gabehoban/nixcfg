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
    (configLib.moduleImport "desktop/desktop-theme.nix")

    # Common desktop services
    (configLib.moduleImport "services/sys-audio.nix")

    # Applications
    (configLib.moduleImport "applications/desktop-1password.nix")
    (configLib.moduleImport "applications/desktop-claude.nix")
    (configLib.moduleImport "applications/desktop-discord.nix")
    (configLib.moduleImport "applications/desktop-firefox.nix")
    (configLib.moduleImport "applications/desktop-steam.nix")
    (configLib.moduleImport "applications/desktop-remmina.nix")
    (configLib.moduleImport "applications/dev-zed.nix")
    (configLib.moduleImport "applications/cli-youtubedl.nix")
  ];
}
