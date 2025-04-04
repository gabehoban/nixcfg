# modules/services/gps-ntp-tools.nix
#
# GPS and NTP related tools for sekio host
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.gpsNtpTools;
in
{
  options = {
    services.gpsNtpTools = {
      enable = mkEnableOption "GPS and NTP related tools";
    };
  };

  config = mkIf cfg.enable {
    # Install GPS and NTP related tools
    environment.systemPackages = with pkgs; [
      # GPS tools
      gpsmon        # GPS monitoring
      gpsd.bin      # GPS command-line tools
      pps-tools     # PPS testing and monitoring
      
      # NTP tools
      chrony        # NTP server/client
      
      # Debugging tools
      tcpdump       # Network packet analysis for NTP
      linuxPackages.perf  # Performance analysis
      
      # Terminal UI tools
      htop          # Process monitoring
      iotop         # I/O monitoring
    ];
    
    # Add a simple status script for checking GPS and NTP status
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "gps-ntp-status" ''
        #!/bin/sh
        echo "=== GPS Status ==="
        echo "GPSD service status:"
        systemctl status gpsd | head -n 20
        
        echo -e "\nGPS device info:"
        if command -v gpsmon >/dev/null 2>&1; then
          gpsmon -n
        else
          echo "gpsmon not found"
        fi
        
        echo -e "\nPPS status:"
        if [ -e /dev/pps0 ]; then
          sudo ppstest /dev/pps0
        else
          echo "PPS device not found"
        fi
        
        echo -e "\n=== NTP Status ==="
        echo "Chrony service status:"
        systemctl status chronyd | head -n 20
        
        echo -e "\nChrony sources:"
        if command -v chronyc >/dev/null 2>&1; then
          chronyc sources
          echo -e "\nTracking info:"
          chronyc tracking
        else
          echo "chronyc not found"
        fi
      '')
    ];
  };
}