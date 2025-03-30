# profiles/applications/gaming.nix
#
# Gaming applications profile
{
  configLib,
  ...
}: {
  imports = [
    # Gaming applications
    (configLib.moduleImport "applications/gaming/default.nix")
  ];
}