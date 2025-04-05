# modules/network/basic.nix
#
# Core networking setup for desktop and server systems
# Provides user-friendly network management and local network discovery
{ lib, ... }:
{
  # Network connection management
  networking = {
    # Use NetworkManager for desktop-friendly network configuration
    # Preferred over wpa_supplicant for its GUI tools and better handling of
    # complex network scenarios like VPNs, captive portals, etc.
    networkmanager.enable = true;

    # Disable built-in firewall in favor of the more advanced firewall module
    # This can be overridden in host configs that don't use the firewall module
    firewall.enable = lib.mkDefault false;
  };

  # Local network service discovery (Avahi/mDNS)
  services.avahi = {
    enable = true;

    # Enable .local hostname resolution without editing /etc/hosts
    # Uses nssmdns4 (IPv4 only version) which has better compatibility
    nssmdns4 = true;

    # Enable both IPv4 and IPv6 to ensure all local devices are discovered
    ipv4 = true;
    ipv6 = true;

    # Advertise this system on the local network for discovery by other devices
    # This makes the device appear in "Network" sections of file browsers
    publish = {
      enable = true;
      addresses = true; # Share IP addresses
      domain = true; # Share domain information
      workstation = true; # Identify as a workstation
    };

    # Allow connections through firewall for mDNS (UDP port 5353)
    openFirewall = true;
  };
}
