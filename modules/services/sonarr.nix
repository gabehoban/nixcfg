# modules/services/sonarr.nix
#
# Sonarr TV series management module
{
  config,
  lib,
  ...
}:
{
  imports = [ ./nginx.nix ];

  # Secret for API key - formatted as SONARR__SECTION__KEY=value
  age.secrets.sonarr-api-key = {
    rekeyFile = ../../secrets/sonarr-api-key.age;
    owner = "sonarr";
    group = "media";
    mode = "0400";
  };

  # NixOS service configuration
  services.sonarr = {
    enable = true;
    group = "media";

    # Use environment variables for configuration
    # This approach is cleaner than generating XML directly
    environmentFiles = [
      config.age.secrets.sonarr-api-key.path
    ];
  };

  # Configure nginx for Sonarr
  services.nginx = {
    enable = true;
    virtualHosts."sonarr.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      # Sonarr proxy configuration
      locations."/" = {
        proxyPass = "http://127.0.0.1:8989";
        proxyWebsockets = true;
      };
    };
  };

  # Harden systemd service
  systemd.services.sonarr = {
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
        "/var/lib/sonarr"
        "/export/media"
      ];
    };
  };

  # Add Sonarr user to the media group for shared access
  users.users.sonarr.extraGroups = [ "media" ];

  # Data persistence
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    "/var/lib/sonarr"
  ];
}
