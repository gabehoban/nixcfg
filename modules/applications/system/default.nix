# modules/applications/system/default.nix
#
# Combined system applications module
# Imports all system-related applications
{
  imports = [
    ./1password.nix
  ];
}