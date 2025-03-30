# modules/applications/development/default.nix
#
# Combined development applications module
# Imports all development-related applications
{
  imports = [
    ./zed.nix
  ];
}