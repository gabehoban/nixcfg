# modules/network/default.nix
#
# Combined networking module
# Imports all networking configurations
{
  imports = [
    ./basic.nix
  ];
}