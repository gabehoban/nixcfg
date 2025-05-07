# modules/network/network.lib.nix
#
# Simplified networking utility functions for host-specific configurations
# These functions have been streamlined after moving standard settings to default.nix
{ lib, ... }:

{
  # Create shared network settings for an organization/home network
  makeSharedNetworking =
    {
      domainName ? "home.arpa", # Local domain name
      localHosts ? { }, # Map of IP -> hostname(s) for local network
      externalHosts ? {
        # External hosts to include
        "1.1.1.1" = [ "cloudflare-dns" ];
        "8.8.8.8" = [ "google-dns" ];
      },
      ...
    }:
    {
      # Define common network settings
      networking = {
        # Set default search domains for DNS resolution
        search = [ domainName ];

        # Common host entries
        hosts = lib.mkMerge [
          # Local network hosts
          localHosts

          # Add important external hosts
          externalHosts
        ];
      };
    };

  # Generate a comprehensive interface configuration for NixOS
  # Creates a complete NetworkManager profile for the specific interface
  makeNetworkInterface =
    {
      interfaceName, # Name of the interface (e.g., "enp1s0")
      ipv6Privacy ? false, # Whether to enable IPv6 privacy extensions (default: false)
      ...
    }:
    {
      # Register the interface with NixOS with minimal settings
      # All actual configuration is handled by NetworkManager
      networking.interfaces.${interfaceName} = { };

      # Create a complete NetworkManager profile for this interface
      # This is the only profile we need - no default fallback required
      networking.networkmanager.ensureProfiles.profiles."nm-${interfaceName}" = {
        connection = {
          id = "nm-${interfaceName}";   # Use the same ID as the profile name for consistency
          type = "ethernet";
          interface-name = interfaceName;
          autoconnect = "true";
          autoconnect-priority = "999";
          "ipv6.addr-gen-mode" = "stable-privacy";
        };
        ipv4 = {
          method = "auto";
          dhcp-timeout = "60";
          dhcp-send-hostname = "true";
        };
        ipv6 = {
          method = "auto";
          addr-gen-mode = "stable-privacy";
          ip6-privacy = if ipv6Privacy then "2" else "0"; # 2=prefer temp addresses, 0=disabled
          ra-timeout = "90";
        };
        proxy = { };
      };

      # Export the primary interface name as a module argument
      _module.args.primaryInterface = interfaceName;
    };

  # Note: The configureChrony function has been migrated to default.nix
  # and renamed to chronyConfigure for better consistency
}
