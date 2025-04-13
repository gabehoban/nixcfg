# modules/services/monitoring.nix
#
# Centralized monitoring setup with Prometheus and Grafana
# Configured for scraping metrics from homelab hosts
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./nginx.nix ];

  users.groups.grafana = { };
  users.users.grafana = {
    group = "grafana";
    isSystemUser = true;
  };

  users.groups.prometheus = { };
  users.users.prometheus = {
    group = "prometheus";
    isSystemUser = true;
  };

  # Prometheus server configuration
  services.prometheus = {
    enable = true;
    port = 9090;

    # Data retention (15 days)
    retentionTime = "15d";

    # Global configuration
    globalConfig = {
      scrape_interval = "15s";
      evaluation_interval = "15s";
    };

    # Enable node exporter for self-monitoring
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "systemd"
          "processes"
          "filesystem"
          "meminfo"
          "netdev"
          "diskstats"
          "cpu"
        ];
        port = 9100;
        openFirewall = true;
      };
    };

    # Scrape configurations
    scrapeConfigs = [
      # Scrape Prometheus itself
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "localhost:9090" ];
            labels = {
              instance = "nuc-titan";
            };
          }
        ];
      }

      # Scrape local node exporter
      {
        job_name = "node-nuc-titan";
        static_configs = [
          {
            targets = [ "localhost:9100" ];
            labels = {
              instance = "nuc-titan";
            };
          }
        ];
      }

      # NUC hosts
      {
        job_name = "node-nuc-juno";
        static_configs = [
          {
            targets = [ "nuc-juno.local:9100" ];
            labels = {
              instance = "nuc-juno";
            };
          }
        ];
      }
      {
        job_name = "node-nuc-luna";
        static_configs = [
          {
            targets = [ "nuc-luna.local:9100" ];
            labels = {
              instance = "nuc-luna";
            };
          }
        ];
      }
    ];
  };

  # Grafana configuration
  services.grafana = {
    enable = true;
    settings.server.http_port = 3000;

    # Provision the Prometheus data source automatically
    provision = {
      enable = true;
      datasources = {
        settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://localhost:9090";
              isDefault = true;
            }
          ];
        };
      };
      # Add basic dashboards
      dashboards = {
        settings = {
          apiVersion = 1;
          providers = [
            {
              name = "default";
              options.path = "/var/lib/grafana/dashboards";
              orgId = 1;
              type = "file";
              disableDeletion = true;
            }
          ];
        };
      };
    };
  };

  # Required packages
  environment.systemPackages = with pkgs; [
    prometheus
    prometheus-node-exporter
    grafana
    pwgen
    curl
  ];

  # Open firewall ports for the services
  networking.firewall.allowedTCPPorts = [
    9090 # Prometheus
    3000 # Grafana
    9100 # Node exporter
  ];

  # Setup default dashboards
  systemd.services.grafana-dashboards = {
    description = "Add default Grafana dashboards";
    wantedBy = [ "multi-user.target" ];
    after = [ "grafana.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "grafana";
      Group = "grafana";
      RemainAfterExit = true;
    };
    script = ''
      # Create dashboard directory
      mkdir -p /var/lib/grafana/dashboards

      # Download Node Exporter dashboard
      ${pkgs.curl}/bin/curl -L -o /var/lib/grafana/dashboards/node-exporter.json https://grafana.com/api/dashboards/1860/revisions/27/download

      # Set proper permissions
      chmod 644 /var/lib/grafana/dashboards/*.json
    '';
  };

  services.nginx = {
    enable = true;
    virtualHosts."grafana.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      locations."/" = {
        proxyPass = "http://localhost:3000";
        proxyWebsockets = true;
      };
    };
    virtualHosts."prometheus.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      locations."/" = {
        proxyPass = "http://localhost:9090";
        proxyWebsockets = true;
      };
    };
  };

  # Create persistable directories
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    {
      directory = "/var/lib/grafana";
      user = "grafana";
      group = "grafana";
    }
    {
      directory = "/var/lib/prometheus2";
      user = "prometheus";
      group = "prometheus";
    }
  ];
}
