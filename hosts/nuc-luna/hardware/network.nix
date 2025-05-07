# hosts/nuc-luna/hardware/network.nix
#
# Network configuration for nuc-luna
# Uses the simplified network interface configuration
{ config, lib, pkgs, configLib, ... }:

let
  # Import the network library directly
  networkLib = import ../../../modules/network/network.lib.nix { inherit lib; };
in
{
  # Import both the standard network interface and the ULA+SLAAC module
  imports = [
    (networkLib.makeNetworkInterface {
      interfaceName = "enp1s0";
      # Server hosts use default IPv6 privacy setting (false)
    })

    # Import ULA IPv6 module
    ../../../modules/network/ula-ipv6.nix
  ];

  # Configure for both SLAAC and ULA IPv6 address
  networking.ula = {
    enable = true;
    interface = "enp1s0";
    address = "fd00:5500:ae00:40::41";
    prefixLength = 64;
  };
}
