# modules/services/prowlarr.nix
#
# Prowlarr indexer management module
{
  config,
  lib,
  ...
}:

{
  imports = [ ./nginx.nix ];

  # Secret for API key - formatted as PROWLARR__SECTION__KEY=value
  age.secrets.prowlarr-api-key = {
    rekeyFile = ../../secrets/prowlarr-api-key.age;
    mode = "0400";
  };

  # NixOS service configuration
  services.prowlarr = {
    enable = true;

    # Use environment variables for configuration
    # This approach is cleaner than generating XML directly
    environmentFiles = [
      config.age.secrets.prowlarr-api-key.path
    ];
  };

  # Configure nginx for Prowlarr
  services.nginx = {
    enable = true;
    virtualHosts."prowlarr.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      # Prowlarr proxy configuration
      locations."/" = {
        proxyPass = "http://127.0.0.1:9696";
        proxyWebsockets = true;
      };
    };
  };

  # Harden systemd service
  systemd.services.prowlarr = {
    serviceConfig = {
      # Restrict system access
      DynamicUser = lib.mkForce false; # Not valid with impermanence mounts
      LockPersonality = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RemoveIPC = true;
      Restart = "on-failure";
      RestartSec = "10s";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";

      # Process capabilities
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;

      # File system restrictions
      ReadWritePaths = [
        "/var/lib/prowlarr"
      ];
    };
  };

  # Firewall rules - only allow internal access to Prowlarr port
  networking.firewall.allowedTCPPorts = [ ];

  # Data persistence
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    "/var/lib/prowlarr"
  ];
}
