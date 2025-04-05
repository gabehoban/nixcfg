# modules/services/gps-monitoring.nix
#
# Specialized monitoring for GPS and NTP services
# Flattened module that enables monitoring specifically for GPS/NTP without options
{ config, lib, pkgs, ... }:

# Direct configuration for GPS/NTP monitoring
{
  # Basic monitoring service with Prometheus exporters specifically for GPS and NTP
  services.prometheus = {
    enable = true;
    
    exporters = {
      # System metrics exporter
      node = {
        enable = true;
        enabledCollectors = [
          "systemd" # Collect systemd service metrics
          "time" # System time
          "diskstats" # Disk I/O statistics
          "textfile" # Custom metrics from text files
        ];
        port = 9100;
        openFirewall = true;
      };
      
      # Chrony metrics exporter (if chrony is enabled)
      chrony = lib.mkIf (config.services.chrony.enable or false) {
        enable = true;
        port = 9123;
        openFirewall = true;
      };
    };
    
    # Basic scrape configuration for local exporters
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = [ "localhost:9100" ];
        }];
      }
      {
        job_name = "chrony";
        static_configs = [{
          targets = [ "localhost:9123" ];
        }];
      }
    ];
  };
  
  # Custom GPSD monitoring using a systemd service and node exporter textfile collector
  systemd.services.gpsd-metrics = lib.mkIf (config.services.gpsd.enable or false) {
    description = "GPSD metrics collection for Prometheus";
    after = [ "gpsd.service" ];
    requires = [ "gpsd.service" ];
    startAt = "*:0/1"; # Run every minute
    path = with pkgs; [ gawk gnugrep gnused gpsd coreutils ];
    
    script = ''
      # Create metrics directory if it doesn't exist
      METRICS_DIR="/var/lib/prometheus-node-exporter/textfile-collector"
      mkdir -p "$METRICS_DIR"
      
      # Collect GPS metrics
      TMPFILE=$(mktemp)
      
      echo "# HELP gpsd_satellites_visible Current number of visible GPS satellites" > $TMPFILE
      echo "# TYPE gpsd_satellites_visible gauge" >> $TMPFILE
      
      # Get satellites count using gpspipe
      SAT_COUNT=$(gpspipe -w -n 10 | grep -m 1 '"satellites":' | awk -F'[:,]' '{print $2}')
      if [ -n "$SAT_COUNT" ]; then
        echo "gpsd_satellites_visible $SAT_COUNT" >> $TMPFILE
      else
        echo "gpsd_satellites_visible 0" >> $TMPFILE
      fi
      
      # Get fix status
      echo "# HELP gpsd_has_fix Whether GPSD has a valid fix (1=yes, 0=no)" >> $TMPFILE
      echo "# TYPE gpsd_has_fix gauge" >> $TMPFILE
      
      FIX_MODE=$(gpspipe -w -n 10 | grep -m 1 '"mode":' | awk -F'[:,]' '{print $2}')
      if [ "$FIX_MODE" -gt 1 ] 2>/dev/null; then
        echo "gpsd_has_fix 1" >> $TMPFILE
      else
        echo "gpsd_has_fix 0" >> $TMPFILE
      fi
      
      # Move temporary file to final location
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
  
  # Ensure text file collector directory exists for node exporter
  systemd.tmpfiles.rules = [
    "d /var/lib/prometheus-node-exporter/textfile-collector 0755 root root -"
  ];
  
  # Install monitoring tools
  environment.systemPackages = with pkgs; [
    prometheus
    prometheus-node-exporter
    prometheus-chrony-exporter
  ];
}