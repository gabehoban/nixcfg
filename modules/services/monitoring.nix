# modules/services/monitoring.nix
#
# System monitoring with Prometheus and Grafana
{ config, lib, pkgs, ... }:

let
  enabled = config.services.monitoring.enable or false;
  prometheus = config.services.monitoring.prometheus or {
    enable = enabled;
    exporters = {
      node = {
        enable = true;
        openFirewall = false;
        port = 9100;
      };
      chrony = {
        enable = config.services.chrony.enable or false;
        openFirewall = false;
        port = 9123;
      };
      gpsd = {
        enable = config.services.gpsd.enable or false;
      };
    };
  };
  
  grafana = config.services.monitoring.grafana or {
    enable = false;
    openFirewall = false;
  };
  
  gpsdServiceEnabled = config.services.gpsd.enable or false;
  chronyServiceEnabled = config.services.chrony.enable or false;
in
{
  # Options interface for host configuration
  options.services.monitoring = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Enable comprehensive system monitoring with Prometheus and Grafana";
    };

    prometheus = {
      enable = mkOption {
        type = types.bool;
        default = config.services.monitoring.enable or false;
        description = mdDoc "Enable Prometheus monitoring server";
      };

      exporters = {
        node = {
          enable = mkOption {
            type = types.bool;
            default = config.services.monitoring.prometheus.enable or false;
            description = mdDoc "Enable Prometheus node exporter";
          };

          openFirewall = mkOption {
            type = types.bool;
            default = false;
            description = mdDoc "Open firewall for node exporter";
          };

          port = mkOption {
            type = types.port;
            default = 9100;
            description = mdDoc "Port for node exporter";
          };
        };

        chrony = {
          enable = mkOption {
            type = types.bool;
            default = (config.services.monitoring.prometheus.enable or false) && chronyServiceEnabled;
            description = mdDoc "Enable Prometheus chrony exporter for NTP metrics";
          };

          openFirewall = mkOption {
            type = types.bool;
            default = false;
            description = mdDoc "Open firewall for chrony exporter";
          };

          port = mkOption {
            type = types.port;
            default = 9123;
            description = mdDoc "Port for chrony exporter";
          };
        };

        gpsd = {
          enable = mkOption {
            type = types.bool;
            default = (config.services.monitoring.prometheus.enable or false) && gpsdServiceEnabled;
            description = mdDoc "Enable GPS metrics collection for Prometheus";
          };
        };
      };
    };

    grafana = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Enable Grafana dashboard";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Open firewall for Grafana web interface";
      };
    };
  };

  # Implementation
  config = lib.mkIf enabled {
    # Node exporter for system metrics
    services.prometheus.exporters.node = lib.mkIf prometheus.exporters.node.enable {
      enable = true;
      openFirewall = prometheus.exporters.node.openFirewall;
      port = prometheus.exporters.node.port;
      enabledCollectors = [
        "systemd" "filesystem" "meminfo" "netdev" "netstat" 
        "stat" "time" "diskstats" "interrupts" "ksmd" 
        "logind" "loadavg" "entropy" "cpu" "cpufreq" 
        "textfile" "bonding" "hwmon" "thermal_zone"
      ];
    };

    # NTP timing metrics
    services.prometheus.exporters.chrony = lib.mkIf prometheus.exporters.chrony.enable {
      enable = true;
      openFirewall = prometheus.exporters.chrony.openFirewall;
      port = prometheus.exporters.chrony.port;
    };

    # GPSD metrics collection for timing quality
    systemd.services.gpsd-metrics = lib.mkIf prometheus.exporters.gpsd.enable {
      description = "GPSD metrics collection for Prometheus";
      after = [ "gpsd.service" ];
      requires = [ "gpsd.service" ];
      startAt = "*:0/1";
      path = with pkgs; [ gawk gnugrep gnused gpsd coreutils ];
      
      script = ''
        METRICS_DIR="/var/lib/prometheus-node-exporter/textfile-collector"
        mkdir -p "$METRICS_DIR"
        
        TMPFILE=$(mktemp)
        
        echo "# HELP gpsd_satellites_visible Current number of visible GPS satellites" > $TMPFILE
        echo "# TYPE gpsd_satellites_visible gauge" >> $TMPFILE
        
        SAT_COUNT=$(gpspipe -w -n 10 | grep -m 1 '"satellites":' | awk -F'[:,]' '{print $2}')
        if [ -n "$SAT_COUNT" ]; then
          echo "gpsd_satellites_visible $SAT_COUNT" >> $TMPFILE
        else
          echo "gpsd_satellites_visible 0" >> $TMPFILE
        fi
        
        echo "# HELP gpsd_has_fix Whether GPSD has a valid fix (1=yes, 0=no)" >> $TMPFILE
        echo "# TYPE gpsd_has_fix gauge" >> $TMPFILE
        
        FIX_MODE=$(gpspipe -w -n 10 | grep -m 1 '"mode":' | awk -F'[:,]' '{print $2}')
        if [ "$FIX_MODE" -gt 1 ] 2>/dev/null; then
          echo "gpsd_has_fix 1" >> $TMPFILE
        else
          echo "gpsd_has_fix 0" >> $TMPFILE
        fi
        
        mv $TMPFILE "$METRICS_DIR/gpsd.prom"
        chmod 644 "$METRICS_DIR/gpsd.prom"
      '';
      
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
        ReadWritePaths = [ "/var/lib/prometheus-node-exporter" ];
      };
    };

    # Create directory for metrics
    systemd.tmpfiles.rules = lib.mkIf (prometheus.exporters.node.enable && prometheus.exporters.gpsd.enable) [
      "d /var/lib/prometheus-node-exporter/textfile-collector 0755 root root -"
    ];

    # Grafana configuration
    services.grafana = lib.mkIf grafana.enable {
      enable = true;
      settings = {
        server = {
          http_port = 3000;
          http_addr = "127.0.0.1";
        };
        auth.anonymous.enabled = false;
      };
    };

    # Nginx reverse proxy for Grafana
    services.nginx = lib.mkIf (grafana.enable && prometheus.exporters.node.enable) {
      enable = true;
      virtualHosts."monitoring.localhost" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:3000";
          proxyWebsockets = true;
        };
      };
    };

    # Firewall rule for Grafana
    networking.firewall.allowedTCPPorts = lib.mkIf (grafana.enable && grafana.openFirewall) [ 3000 ];
  };
}