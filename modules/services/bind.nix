# modules/services/bind.nix
#
# BIND/named DNS server configuration
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable BIND service
  services.bind = {
    enable = true;

    # Configure zones
    configFile = pkgs.writeText "named.conf" (
      ''
        acl cachenetworks { 127.0.0.0/8; 10.0.0.0/8; };
        acl badnetworks   { };
        options {
          listen-on    { any; };
          listen-on-v6 { any; };
          allow-query  { cachenetworks; };
          blackhole    { badnetworks;   };

          directory "/run/named";
          pid-file  "/run/named/named.pid";

          forward only;
          forwarders {
            1.1.1.1;
            9.9.9.9;
          };
        };
      ''
      + (
        let
          domain = "labrats.cc";
        in
        ''
          zone "${domain}" {
            type master;
            file "${pkgs.writeText "${domain}.zone" ''
              $TTL    604800
              @       IN      SOA     ns.${domain}. admin.labrats.cc. (2024040603 3600 1800 604800 86400)
              @       IN      NS      ns.${domain}.
              ns      IN      A       10.32.40.42
              plex    IN      A       10.32.40.41
              sonarr  IN      A       10.32.40.43
              radarr  IN      A       10.32.40.43
              prowlarr IN     A       10.32.40.43
              sabnzbd IN      A       10.32.40.43
              minio-luna  IN  A       10.32.40.41
              minio-juno  IN  A       10.32.40.43
              cache   IN      A       10.32.40.42
            ''}";
          };
        ''
      )
    );
  };

  # Configure firewall to allow DNS traffic
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  # Add DNS utilities
  environment.systemPackages = with pkgs; [
    dig
    whois
    dnsutils
  ];

  # Data persistence for BIND
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    "/var/lib/bind"
  ];

  # Disable systemd-resolved to avoid port conflicts
  services.resolved.enable = false;
}
