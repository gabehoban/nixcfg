# modules/services/radarr.nix
#
# Radarr movie management module
{
  config,
  lib,
  ...
}:

{
  imports = [ ./nginx.nix ];

  # Secret for API key - formatted as RADARR__SECTION__KEY=value
  age.secrets.radarr-api-key = {
    rekeyFile = ../../secrets/radarr-api-key.age;
    owner = "radarr";
    group = "media";
    mode = "0400";
  };

  # NixOS service configuration
  services.radarr = {
    enable = true;
    group = "media";

    # Use environment variables for configuration
    # This approach is cleaner than generating XML directly
    environmentFiles = [
      config.age.secrets.radarr-api-key.path
    ];
  };

  # Configure nginx for Radarr
  services.nginx = {
    enable = true;
    virtualHosts."radarr.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      # Radarr proxy configuration
      locations."/" = {
        proxyPass = "http://127.0.0.1:7878";
        proxyWebsockets = true;
      };
    };
  };

  # Harden systemd service
  systemd.services.radarr = {
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
        "/var/lib/radarr"
        "/export/media"
      ];
    };
  };

  # Add Radarr user to the media group for shared access
  users.users.radarr.extraGroups = [ "media" ];

  # Data persistence
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    "/var/lib/radarr"
  ];
}
