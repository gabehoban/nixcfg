# modules/services/storage-minio.nix
#
# MinIO object storage service configuration
{
  config,
  lib,
  ...
}:

{
  imports = [ ./web-nginx.nix ];

  # Secret for root credentials
  age.secrets.minio-root-credentials = {
    rekeyFile = ../../secrets/minio-root-credentials.age;
    mode = "0400";
    owner = "minio";
    group = "minio";
  };

  services.minio = {
    enable = true;

    # Common configuration
    region = "homelab";
    browser = true;

    # Security
    rootCredentialsFile = config.age.secrets.minio-root-credentials.path;

    # Data configuration - will be set per-host
    dataDir = [ ];
  };

  # Configure nginx for MinIO
  services.nginx = {
    enable = true;

    # MinIO API virtual host
    virtualHosts."minio.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      # MinIO API proxy
      locations."/" = {
        proxyPass = "http://minio-vip:9000";
        proxyWebsockets = true;
      };
    };

    # MinIO Console virtual host
    virtualHosts."minio-console.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      # MinIO Console proxy
      locations."/" = {
        proxyPass = "http://minio-vip:9001";
        proxyWebsockets = true;
      };
    };
  };

  # Allow required ports for MinIO and VRRP protocol
  networking.firewall = {
    allowedTCPPorts = [
      9000
      9001
    ];
  };

  # For distributed mode, hosts need to be able to communicate
  networking.hosts = {
    "10.32.40.41" = [ "nuc-luna" ];
    "10.32.40.43" = [ "nuc-juno" ];
    "10.32.40.45" = [ "minio-vip" ];
  };

  # Data persistence
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    "/var/lib/minio"
  ];
}
