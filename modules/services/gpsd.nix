# modules/services/gpsd.nix
#
# GPS daemon service configuration for Raspberry Pi GPS HAT
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # GPS daemon configuration
  services.gpsd = {
    enable = true;
    
    # Configure for Raspberry Pi GPS HAT on GPIO pins
    # Include both the serial device and the PPS device
    devices = [ 
      "/dev/ttyAMA0"  # Serial NMEA data from GPS
      "/dev/pps0"     # Pulse Per Second for precise timing
    ];
    
    # Set to false as we need to configure the device
    readonly = false;
    
    # Listen on all network interfaces
    listenany = true;
    
    # Poll GPS even without clients connected to ensure
    # continuous operation and data collection
    nowait = true;
    
    # Extra arguments
    extraArgs = [
      # Speed (baud rate) for the serial device
      "-s" "115200"
      # Create shared memory segments that chrony can use
      "-n"
    ];
  };

  # Install useful tools for working with GPS
  environment.systemPackages = with pkgs; [
    gpsd        # GPS daemon
    gpsd.bin    # GPS command-line tools
    pps-tools   # PPS testing and monitoring
  ];
  
  # Ensure gpsd starts before chrony
  systemd.services.chronyd.after = [ "gpsd.service" ];
  systemd.services.chronyd.wants = [ "gpsd.service" ];

  # Configure udev to ensure proper device permissions
  services.udev.extraRules = ''
    # GPS Serial device
    KERNEL=="ttyAMA0", OWNER="gpsd", GROUP="dialout", MODE="0660"
    
    # PPS device
    KERNEL=="pps0", OWNER="gpsd", GROUP="dialout", MODE="0660"
  '';

  # Persistence configuration for GPS data
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/gpsd"
    ];
  };
}