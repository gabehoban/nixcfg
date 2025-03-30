# modules/applications/default.nix
#
# Combined applications module
# Imports all application modules by category
{
  imports = [
    ./browser
    ./communication
    ./development
    ./gaming
    ./productivity
    ./system
  ];
}