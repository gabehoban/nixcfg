# modules/services/gps-ntp-tools.nix
#
# GPS and NTP related tools for monitoring and diagnostics
# Flattened module that installs tools and monitoring services for GPS/NTP
{ config, lib, pkgs, ... }:

# Direct configuration that is applied when this module is imported
let
  # Check if required services are enabled
  gpsdEnabled = config.services.gpsd.enable or false;
  chronyEnabled = config.services.chrony.enable or false;
  
  # Default values
  statusInterval = 300; # 5 minutes
  logRetention = 7; # days
  reportDirectory = "/var/lib/gps-ntp-monitor";
  autoRecovery = true;
  
  # Helper function to create a properly escaped shell script
  gpsStatusScript = pkgs.writeShellScriptBin "gps-ntp-status" ''
    #!/bin/bash
    # Enhanced GPS/NTP status script with error handling and diagnostics

    # Define colors for output
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    NC=$(tput sgr0)

    # Function to check service status
    check_service() {
      local service_name=$1
      local status=$(systemctl is-active $service_name)
      
      echo -e "Service ''${BLUE}$service_name''${NC}: \c"
      if [[ "$status" == "active" ]]; then
        echo -e "''${GREEN}Running''${NC}"
        return 0
      else
        echo -e "''${RED}$status''${NC}"
        return 1
      fi
    }

    # Function to check device existence
    check_device() {
      local device=$1
      local description=$2
      
      echo -e "$description ''${BLUE}$device''${NC}: \c"
      if [[ -e $device ]]; then
        echo -e "''${GREEN}Present''${NC}"
        return 0
      else
        echo -e "''${RED}Not found''${NC}"
        return 1
      fi
    }

    # Main status header
    echo -e "''${BLUE}====================================''${NC}"
    echo -e "''${BLUE}= GPS and NTP Status Report       =''${NC}"
    echo -e "''${BLUE}====================================''${NC}"
    echo

    # Check GPS service status
    echo -e "''${YELLOW}=== GPS Service Status ===''${NC}"
    if check_service gpsd; then
      # Get more detailed status
      echo -e "\nDetails:"
      systemctl status gpsd | head -n 10
    else
      echo -e "\n''${RED}GPSD service is not running correctly.''${NC}"
      echo "Possible solutions:"
      echo "  1. Verify hardware connections"
      echo "  2. Check if device exists: ls -l /dev/ttyAMA0"
      echo "  3. Restart service: sudo systemctl restart gpsd"
      echo
    fi

    # Check hardware devices 
    echo -e "\n''${YELLOW}=== GPS Hardware Status ===''${NC}"
    check_device "/dev/ttyAMA0" "GPS serial device"
    check_device "/dev/pps0" "PPS timing device"

    # Try to get GPS data
    echo -e "\n''${YELLOW}=== GPS Data ===''${NC}"
    if command -v gpspipe >/dev/null 2>&1; then
      echo "GPS data (waiting for 3 seconds for data):"
      timeout 3 gpspipe -w 2>/dev/null || echo -e "''${RED}No GPS data received''${NC}"
    else
      echo -e "''${RED}gpspipe not found''${NC}"
    fi

    # PPS status 
    echo -e "\n''${YELLOW}=== PPS Status ===''${NC}"
    if [ -e /dev/pps0 ]; then
      echo "Testing PPS device (waiting for 5 seconds for pulse):"
      timeout 5 sudo ppstest /dev/pps0 || echo -e "''${RED}No PPS pulse detected''${NC}"
    else
      echo -e "''${RED}PPS device not found. Kernel modules may not be loaded.''${NC}"
    fi

    # Check NTP service
    echo -e "\n''${YELLOW}=== NTP Service Status ===''${NC}"
    if check_service chronyd; then
      echo -e "\nDetails:"
      systemctl status chronyd | head -n 10
    else
      echo -e "\n''${RED}Chrony service is not running correctly.''${NC}"
      echo "Possible solutions:"
      echo "  1. Check configuration: cat /etc/chrony/chrony.conf"
      echo "  2. Restart service: sudo systemctl restart chronyd"
      echo
    fi

    # Check NTP sources and tracking
    echo -e "\n''${YELLOW}=== NTP Sources & Tracking ===''${NC}"
    if command -v chronyc >/dev/null 2>&1; then
      chronyc sources
      echo -e "\nTracking info:"
      chronyc tracking
    else
      echo -e "''${RED}chronyc not found''${NC}"
    fi

    # Check kernel modules
    echo -e "\n''${YELLOW}=== Required Kernel Modules ===''${NC}"
    for module in pps_core pps_gpio pps_ldisc; do
      echo -e "Module ''${BLUE}$module''${NC}: \c"
      if lsmod | grep -q $module; then
        echo -e "''${GREEN}Loaded''${NC}"
      else
        echo -e "''${RED}Not loaded''${NC}"
      fi
    done

    echo -e "\n''${BLUE}====================================''${NC}"
    echo -e "''${BLUE}= End of Status Report            =''${NC}"
    echo -e "''${BLUE}====================================''${NC}"
  '';
  
  # Recovery service script
  monitorScript = pkgs.writeShellScript "gps-ntp-monitor" ''
    #!/bin/bash
    
    # Function to check and restart a service if needed
    check_and_restart() {
      local service=$1
      local max_restarts=$2
      local restart_count=0
      
      # Check if service is active
      if ! systemctl is-active --quiet $service; then
        echo "$(date): $service is not running, attempting restart..."
        
        while ! systemctl is-active --quiet $service && [ $restart_count -lt $max_restarts ]; do
          systemctl restart $service
          restart_count=$((restart_count + 1))
          echo "$(date): Restart attempt $restart_count for $service"
          sleep 10
        done
        
        if systemctl is-active --quiet $service; then
          echo "$(date): $service successfully restarted"
        else
          echo "$(date): Failed to restart $service after $max_restarts attempts"
        fi
      fi
    }
    
    # Main monitoring loop
    while true; do
      # Check GPS service
      check_and_restart gpsd 3
      
      # Check chrony service
      check_and_restart chronyd 3
      
      # Check PPS device and reload kernel module if needed
      if [ ! -e /dev/pps0 ] && lsmod | grep -q pps_gpio; then
        echo "$(date): PPS device missing, reloading pps_gpio kernel module..."
        modprobe -r pps_gpio
        sleep 2
        modprobe pps_gpio
      fi
      
      # Sleep before next check
      sleep ${toString statusInterval}
    done
  '';
in
{
  # Add assertions to ensure required services are enabled
  assertions = [
    {
      assertion = gpsdEnabled;
      message = "gps-ntp-tools module requires gpsd service to be enabled.";
    }
    {
      assertion = chronyEnabled;
      message = "gps-ntp-tools module requires chrony service to be enabled.";
    }
  ];

  # Install GPS and NTP related tools and status script
  environment.systemPackages = with pkgs; [
    # GPS tools
    gpsd # GPS daemon that includes gpsmon and gpspipe
    pps-tools # PPS testing and monitoring

    # NTP tools
    chrony # NTP server/client

    # Debugging tools
    tcpdump # Network packet analysis for NTP
    linuxPackages.perf # Performance analysis

    # Terminal UI tools
    htop # Process monitoring
    iotop # I/O monitoring
    
    # Status script
    gpsStatusScript
  ];

  # Add automatic recovery service
  systemd.services.gps-ntp-monitor = {
    description = "GPS and NTP Monitoring and Recovery Service";
    
    # Run after GPS and chrony are started
    after = [ "gpsd.service" "chrony.service" ];
    
    # Make sure it's restarted if it fails
    startLimitIntervalSec = 300;
    startLimitBurst = 5;
    
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "30s";
      ExecStart = "${monitorScript}";
      
      # Security settings
      User = "root";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
    };
    
    wantedBy = [ "multi-user.target" ];
  };
  
  # Create the report directory
  systemd.tmpfiles.rules = [
    "d ${reportDirectory} 0755 root root ${toString logRetention}d"
  ];
}