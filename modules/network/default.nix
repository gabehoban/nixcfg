# modules/network/default.nix
#
# Combined networking module - imports all networking configurations
# Flattened module with direct imports and network definitions
{
  lib,
  config,
  ...
}:

{
  # Import all network-related modules
  imports = [
    # Basic networking configuration
    ./basic.nix
    # IPv6 support
    ./ipv6.nix
    # Standard NixOS firewall
    ./net-firewall.nix
  ];

  # Define trusted networks for use throughout the configuration
  options.networking.trusted = {
    networks = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        loopback = "127.0.0.1/8";
        homeNetwork = "10.32.0.0/16"; # More specific home network range
      };
      description = lib.mdDoc "Dictionary of trusted networks for firewall and security configurations";
    };
  };

  # Apply the configuration - make trusted networks available throughout the configuration
  config = {
    _module.args.trustedNetworks = config.networking.trusted.networks;
  };
}
