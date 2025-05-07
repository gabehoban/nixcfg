# Realtek R8125 2.5G Network Driver Configuration
{
  config,
  lib,
  ...
}:

let
  # Import the network library directly
  networkLib = import ../../../../modules/network/network.lib.nix { inherit lib; };
in
{
  # Set the primary interface name as a module argument with high priority
  # Note: eno1 is the actual interface name, r8125 is just the driver
  _module.args = {
    primaryInterface = lib.mkForce "eno1";
  };

  # Custom module for Realtek 2.5G network adapter (RTL8125)
  # This works around compatibility issues with the default r8169 driver
  boot = {
    # Load custom driver module from the local definition
    extraModulePackages = [
      (config.boot.kernelPackages.callPackage ./realtek-r8125-module.nix { })
    ];

    # Blacklist the default r8169 driver which conflicts with r8125
    blacklistedKernelModules = [ "r8169" ];
  };

  # Generate comprehensive network configuration using the enhanced library function
  # Interface-specific settings are now fully defined in the NetworkManager profile
  imports = [
    (networkLib.makeNetworkInterface {
      interfaceName = "eno1";
      ipv6Privacy = true;  # Enable IPv6 privacy extensions for workstation
    })
  ];
}
