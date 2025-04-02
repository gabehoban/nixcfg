# modules/network/basic.nix
#
# Basic network configuration
# Configures NetworkManager, firewall, and mDNS discovery
_: {
  # Network management settings
  networking = {
    # Use NetworkManager for handling network connections
    networkmanager.enable = true;

    # Disable firewall (note: consider security implications)
    firewall.enable = false;
  };

  # Service discovery configuration
  services.avahi = {
    # Enable mDNS/DNS-SD service discovery (Avahi)
    enable = true;

    # Enable multicast DNS NSS lookup for .local domains
    nssmdns4 = true;

    # Automatically open necessary ports in the firewall
    openFirewall = true;
  };
}
