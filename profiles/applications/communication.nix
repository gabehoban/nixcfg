# profiles/applications/communication.nix
#
# Communication applications profile
{
  configLib,
  ...
}: {
  imports = [
    # Communication applications
    (configLib.moduleImport "applications/app-discord.nix")
  ];
}