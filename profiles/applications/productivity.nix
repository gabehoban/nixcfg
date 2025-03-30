# profiles/applications/productivity.nix
#
# Productivity applications profile
{
  configLib,
  ...
}: {
  imports = [
    # Productivity applications
    (configLib.moduleImport "applications/app-claude.nix")
  ];
}