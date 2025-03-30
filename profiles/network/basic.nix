# profiles/network/basic.nix
#
# Basic network profile with all essential networking features
{
  configLib,
  ...
}: {
  imports = [
    # Import all network modules
    (configLib.moduleImport "network/default.nix")
  ];
}