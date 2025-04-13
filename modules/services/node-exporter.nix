# modules/services/node-exporter.nix
#
# Prometheus Node Exporter configuration for target hosts
# Enables metrics collection to be scraped by Prometheus
{
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
    ];
    port = 9100;
    openFirewall = true;
  };

  # Install node exporter package
  environment.systemPackages = with pkgs; [
    prometheus-node-exporter
  ];
}
