# modules/applications/communication/default.nix
#
# Combined communication applications module
# Imports all communication-related applications
{
  imports = [
    ./discord.nix
  ];
}