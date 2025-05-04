# modules/services/web-nginx.nix
#
# Base Nginx module for web server functionality
{
  config,
  lib,
  ...
}:

{
  # Import certificates module
  imports = [ ../core/certificates.nix ];

  # Enable Nginx (will be explicitly enabled by dependent services)
  services.nginx = {
    enable = lib.mkDefault false;

    # Recommended settings for security
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Security headers
    commonHttpConfig = ''
      # Security headers
      add_header X-Content-Type-Options nosniff;
      add_header X-XSS-Protection "1; mode=block";
      add_header Referrer-Policy same-origin;
    '';

    # Default SSL settings for all virtual hosts
    sslCiphers = lib.mkDefault "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305";
    sslProtocols = lib.mkDefault "TLSv1.3 TLSv1.2";
  };

  # Add nginx user to the ssl-cert group to access wildcard certificates
  users.users.nginx.extraGroups = lib.mkIf config.services.nginx.enable [ "ssl-cert" ];

  # Persistence for Nginx data
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    "/var/log/nginx"
    "/var/lib/nginx"
  ];

  # Open firewall ports when Nginx is enabled
  networking.firewall.allowedTCPPorts = lib.mkIf config.services.nginx.enable [
    80 # HTTP
    443 # HTTPS
  ];
}
