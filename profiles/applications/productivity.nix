# profiles/applications/productivity.nix
#
# Productivity applications profile
{
  configLib,
  ...
}: {
  imports = [
    # Productivity applications
    (configLib.moduleImport "applications/productivity/default.nix")
  ];
}