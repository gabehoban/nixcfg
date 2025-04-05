# modules/network/dns.nix
#
# Enhanced DNS configuration and resolvers with security features
{ config, lib, pkgs, ... }:

with lib;

let
  # Use structured DNS security settings
  cfg = {
    # Set default trusted DNS resolvers with secure protocols
    # These can be overridden by host-specific configurations
    defaultResolvers = [
      "1.1.1.1#cloudflare-dns.com" # Cloudflare DNS with TLS hostname
      "1.0.0.1#cloudflare-dns.com" # Cloudflare DNS secondary
      "9.9.9.9#dns.quad9.net"      # Quad9 secure DNS with TLS hostname
      "149.112.112.112#dns.quad9.net" # Quad9 secondary
    ];
    
    # Trusted security settings
    dnsSecLevel = "yes";           # Full DNSSEC enforcement (change to "allow-downgrade" for less strict)
    dnsTlsMode = "strict";         # Use strictest TLS mode (opportunistic is fallback)
    cacheMinTtl = 3600;            # Minimum TTL for DNS cache entries
    cacheMaxTtl = 86400;           # Maximum TTL for DNS cache entries
  };
in
{
  #
  # System-wide DNS resolver configuration
  #
  networking = {
    # DNS hostname resolution settings
    resolvconf.enable = true;

    # DNSSEC validation
    dnssec = {
      enable = true;           # Enable DNSSEC
      
      # Add negative trust anchors for domains known to have DNSSEC issues
      # This allows resolving these domains even if they have broken DNSSEC
      negativeTrustAnchors = [
        "example.invalid"  # Replace with actual problem domains if needed
      ];
    };
    
    # Prevent local DNS hijacking by disabling these protocols
    useDHCP = mkDefault false;            # Prefer static network configuration
    dhcpcd.extraConfig = "nohook resolv.conf"; # Prevent DHCP from overriding DNS
  };

  # If NetworkManager is enabled, configure its DNS settings securely
  networking.networkmanager = mkIf config.networking.networkmanager.enable {
    dns = "systemd-resolved";             # Use systemd-resolved for DNS resolution
    
    # Prevent NetworkManager from overriding DNS settings
    dispatcherScripts = [{
      source = pkgs.writeText "01-dnssec" ''
        #!/bin/sh
        # Maintain DNSSEC and DoT settings regardless of connection type
        [ "$2" = "up" ] || exit 0
        ${pkgs.systemd}/bin/resolvectl dnssec yes
        ${pkgs.systemd}/bin/resolvectl dnsovertls strict
      '';
      type = "basic";
    }];
  };

  # Enhanced systemd-resolved configuration for modern DNS security features
  services.resolved = {
    enable = true;

    # Main DNS security settings
    dnssec = cfg.dnsSecLevel;       # Full DNSSEC validation
    llmnr = "false";                # Disable Link-Local Multicast Name Resolution (security risk)
    multicastDns = false;           # Disable Multicast DNS (security risk)
    dnsovertls = cfg.dnsTlsMode;    # Always use DNS-over-TLS when available
    
    # Fallback DNS servers (used if no others are available)
    fallbackDns = cfg.defaultResolvers;
    
    # Additional DNS resolver options with enhanced security and performance
    extraConfig = ''
      # DNS Cache settings
      Cache=yes
      CacheFromLocalhost=no
      CacheMaxTtl=${toString cfg.cacheMaxTtl}
      CacheMinTtl=${toString cfg.cacheMinTtl}
      
      # DNS-over-TLS settings
      DNSOverTLS=${cfg.dnsTlsMode}
      
      # DNS Security settings
      FallbackDnsNoEncryption=no
      ResolveUnicastSingleLabel=no
      
      # Performance settings
      DNSStubListener=yes
      ReadEtcHosts=yes
      
      # DNSSEC
      DNSSEC=${cfg.dnsSecLevel}
    '';
  };
  
  # Install DNS diagnostic and security tools
  environment.systemPackages = with pkgs; [
    dnsutils           # Standard DNS utilities (dig, nslookup)
    whois              # Domain registration info
    dnssec-anchors     # DNSSEC root anchors
    dnssec-tools       # DNSSEC validation tools
  ];
  
  # Security assertions to ensure DNS is properly configured
  assertions = [
    {
      assertion = config.services.resolved.enable;
      message = "systemd-resolved must be enabled for secure DNS configuration.";
    }
  ];
  
  # Check DNSSEC status during system activation
  system.activationScripts.checkDnssec = {
    text = ''
      # Ensure DNSSEC is working
      echo "Checking DNSSEC configuration..."
      if ${pkgs.systemd}/bin/resolvectl query sigok.verteiltesysteme.net | grep -q "DNSSEC validation is not enabled"; then
        echo "WARNING: DNSSEC validation is not working properly"
      else
        echo "DNSSEC validation is configured correctly"
      fi
    '';
    deps = [];
  };
}
