# modules/applications/productivity/default.nix
#
# Combined productivity applications module
# Imports all productivity-related applications
{
  imports = [
    ./claude.nix
  ];
}