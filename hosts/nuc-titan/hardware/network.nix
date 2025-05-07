# hosts/nuc-titan/hardware/network.nix
#
# Network configuration for nuc-titan
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
      interfaceName = "enp2s0";
      # Server hosts use default IPv6 privacy setting (false)
    })

    # Import ULA IPv6 module
    ../../../modules/network/ula-ipv6.nix
  ];

  # Configure for both SLAAC and ULA IPv6 address
  networking.ula = {
    enable = true;
    interface = "enp2s0";
    address = "fd00:5500:ae00:40::42";
    prefixLength = 64;
  };
}
