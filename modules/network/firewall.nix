# modules/network/firewall.nix
#
# Standard NixOS firewall configuration module
# This module uses the default NixOS firewall configuration
{
  config,
  lib,
  ...
}:

{
  # Enable the default NixOS firewall
  config = {
    networking.firewall = {
      enable = true;
      allowPing = true;
    };

    # Ensure SSH is always accessible
    networking.firewall.allowedTCPPorts = lib.mkDefault [ 22 ];
  };
}
