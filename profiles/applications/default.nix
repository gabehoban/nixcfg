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
    (configLib.moduleImport "applications/system/default.nix")
    
    # Development tools
    (configLib.moduleImport "applications/development/default.nix")
  ];
}