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

  # Required kernel modules for VRRP
  boot.kernelModules = [ "ip_vs" ];

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

  services.keepalived = {
    enable = true;
    vrrpInstances = {
      "minio-vip" = {
        # Different priority for each node (higher is preferred)
        priority = lib.mkDefault 100;

        # Interface to bind the VIP to
        interface = "eth0";

        # Virtual router ID (must be the same across all nodes in the cluster)
        virtualRouterId = 42;

        # VIP address configuration
        virtualIps = [
          {
            addr = "10.32.40.45/24";
          }
        ];
      };
    };
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

    # Allow VRRP protocol for keepalived
    extraCommands = ''
      # Allow VRRP protocol (necessary for keepalived)
      iptables -A INPUT -p vrrp -j ACCEPT
      ip6tables -A INPUT -p vrrp -j ACCEPT
    '';
  };

  # Ensure proper service ordering
  systemd.services.minio.after = [ "keepalived.service" ];
  systemd.services.minio.wants = [ "keepalived.service" ];

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
