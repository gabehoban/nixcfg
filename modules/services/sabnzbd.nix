# modules/services/sabnzbd.nix
#
# SABnzbd Usenet downloader module
{
  config,
  lib,
  ...
}:

{
  imports = [ ./nginx.nix ];

  # NixOS service configuration
  services.sabnzbd = {
    enable = true;
    group = "media";
  };

  # Configure nginx for SABnzbd
  services.nginx = {
    enable = true;
    virtualHosts."sabnzbd.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      # SABnzbd proxy configuration
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
      };
    };
  };

  # Harden systemd service
  systemd.services.sabnzbd = {
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
        "/var/lib/sabnzbd"
        "/export/media"
      ];
    };
  };

  # Add SABnzbd user to the media group for shared access
  users.users.sabnzbd.extraGroups = [ "media" ];

  # Data persistence
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    "/var/lib/sabnzbd"
  ];
}
