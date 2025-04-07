# modules/services/attic.nix
#
# Attic Nix binary cache server
{
  config,
  lib,
  ...
}:

{
  imports = [ ./nginx.nix ];

  users = {
    groups.attic = { };
    users.attic = {
      group = "attic";
      home = "/var/empty";
      isSystemUser = true;
    };
  };

  # Secret for Attic (includes S3 credentials)
  age.secrets.attic-credentials = {
    rekeyFile = ../../secrets/attic-credentials.age;
    owner = "attic";
    group = "attic";
    mode = "0400";
  };

  # NixOS Attic service configuration
  services.atticd = {
    enable = true;

    # Server settings
    settings = {
      api-endpoint = "https://cache.labrats.cc/";
      listen = "[::]:8080";
      jwt = { };

      database = {
        url = "sqlite:///var/lib/atticd/server.db?mode=rwc";
      };

      # Use S3/Minio as storage backend
      storage = {
        type = "s3";
        region = "homelab";
        bucket = "nix-cache";
        endpoint = "http://10.32.40.41:9000";
      };

      compression.type = "zstd";
      chunking = {
        nar-size-threshold = 65536;
        min-size = 16384;
        avg-size = 65536;
        max-size = 262144;
      };
      garbage-collection = {
        interval = "24h";
        default-retention-period = "30d";
      };
    };

    # Use a dedicated user
    user = "attic";
    group = "attic";

    # For improved security and S3 credentials
    environmentFile = config.age.secrets.attic-credentials.path;
  };
  systemd.services.atticd.serviceConfig.DynamicUser = lib.mkForce false;

  # Configure nginx for Attic
  services.nginx = {
    enable = true;
    virtualHosts."cache.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      # Attic binary cache proxy configuration
      locations."/" = {
        proxyPass = "http://localhost:8080";
        proxyWebsockets = true;

        # Nix-specific headers and timeouts
        extraConfig = ''
          # Allow large uploads
          client_max_body_size 1000M;

          # Increase timeouts for slow uploads/downloads
          proxy_read_timeout 600;
          proxy_send_timeout 600;
        '';
      };
    };
  };

  # Firewall settings - allow internal access directly
  networking.firewall.allowedTCPPorts = [ 8080 ];

  # Data persistence
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    "/var/lib/atticd"
  ];
}
