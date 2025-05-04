# modules/services/mon-node-exporter.nix
#
# Comprehensive monitoring configuration for target hosts
# Includes:
# - Prometheus Node Exporter with extended collectors
# - Systemd exporter for service health monitoring
# - Nginx exporter (if nginx is enabled)
# - Promtail for log collection and forwarding to Loki
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable the Prometheus node exporter
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "systemd"
      "processes"
      "filesystem"
      "meminfo"
      "netdev"
      "diskstats"
      "cpu"
      "loadavg"
      "time"
      "interrupts"
      "ksmd"
      "logind"
      "ntp"
      "stat"
      "tcpstat"
      "vmstat"
    ];
    port = 9100;
    openFirewall = true;
  };

  # Install node exporter package
  environment.systemPackages = with pkgs; [
    prometheus-node-exporter
  ];

  # Add systemd exporter for service health monitoring
  services.prometheus.exporters.systemd = {
    enable = true;
    port = 9558;
    openFirewall = true;
  };

  # Install promtail for log collection (if not already installed)
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 28183;
        grpc_listen_port = 0;
      };

      positions = {
        filename = "/var/lib/promtail/positions.yaml";
      };

      clients = [
        {
          # Point to your central Loki instance
          url = "http://nuc-titan.local:3100/loki/api/v1/push";
        }
      ];

      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = config.networking.hostName;
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
          ];
        }
      ];
    };
  };
  systemd.services.promtail.serviceConfig.DynamicUser = false;

  # Open firewall port for promtail if it's enabled
  networking.firewall.allowedTCPPorts = lib.mkIf (config.services.promtail.enable or false) [
    28183 # Promtail HTTP API
  ];

  # Create persistable directories for promtail
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    {
      directory = "/var/lib/promtail";
      user = "promtail";
      group = "promtail";
    }
  ];
}
