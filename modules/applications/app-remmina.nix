# modules/applications/app-remmina.nix
#
# Remmina client configuration
{
  pkgs,
  ...
}:
{
  #
  # Remmina application and dependencies
  #
  environment.systemPackages = [
    # Remmina program
    pkgs.remmina
  ];

  #
  # Persistence configuration
  #
  impermanence.users.gabehoban.directories = [
    # Persist Remmina configuration across reboots
    ".config/remmina"
    ".local/share/remmina"
  ];
}
