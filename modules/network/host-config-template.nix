# modules/network/host-config-template.nix
#
# Host networking configuration template
# Copy this file to your host's hardware directory as 'network.nix'
# and customize it for your specific host
{ config, lib, ... }:

# IMPORTANT: This file is a TEMPLATE and should not be imported directly
# Copy this to your host directory (e.g., hosts/your-host/hardware/network.nix)
# Then customize the interface name and other settings as needed
let
  # Import the network library directly
  networkLib = import ../../modules/network/network.lib.nix { inherit lib; };

  # Set the primary interface name (customize this for each host)
  # Common examples: enp1s0, eth0, eno1, wlan0
  interfaceName = "enp1s0";
in
{
  # The primary interface name is now set by makeNetworkInterface
  # No need to set it explicitly with _module.args

  # Configure the interface using the network library
  # This minimal configuration is sufficient for most hosts as
  # standard settings are now defined in default.nix
  imports = [
    (networkLib.makeNetworkInterface {
      interfaceName = interfaceName;
    })
  ];

  # For advanced configuration needs:
  #
  # NOTE: Network configuration has been standardized using the global 10-default-settings
  # All interfaces use the same configuration defined in modules/network/default.nix
  # This is intentional to ensure consistent networking behavior across all hosts.
  # Only the interface name needs to be customized per host.

  # Note: Time synchronization (chrony) is standardized across all hosts
  # and cannot be customized per-host. The configuration is defined in
  # modules/network/default.nix and is enforced with lib.mkForce.
}
