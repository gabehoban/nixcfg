# modules/network/default.nix
#
# Combined networking module
# Imports all networking configurations
{
  lib,
  config,
  ...
}:
{
  imports = [
    # Basic networking configuration
    ./basic.nix
  ];

  # Network configuration options for clarity and centralization
  options.networking.trusted = {
    networks = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        loopback = "127.0.0.1/8";
        homeNetwork = "10.32.0.0/16"; # More specific home network range
      };
      description = "Dictionary of trusted networks for firewall and security configurations";
    };
  };

  # Apply the configuration
  config = {
    # Make trusted networks available throughout the configuration
    _module.args.trustedNetworks = config.networking.trusted.networks;
  };
}
