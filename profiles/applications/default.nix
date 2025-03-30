# profiles/applications/default.nix
#
# Default applications profile
# Includes common applications most users would want
{
  configLib,
  ...
}: {
  imports = [
    # Web browsers
    (configLib.profileImport "applications/browser.nix")

    # System utilities
    (configLib.moduleImport "applications/app-1password.nix")

    # Development tools
    (configLib.moduleImport "applications/app-zed.nix")
  ];
}