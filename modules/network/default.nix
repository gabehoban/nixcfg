# modules/network/default.nix
#
# Combined networking module
# Imports all networking configurations
{
  ...
}:
{
  #
  # Module imports
  #
  imports = [
    # Basic networking configuration
    ./basic.nix
  ];
}
