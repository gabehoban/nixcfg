{
  configLib,
  inputs,
  ...
}:
{
  networking.hostName = "sekio";
  
  # Generate a proper unique host ID (replace with a real random value)
  networking.hostId = "fe8e9a31";
  
  # Enable mDNS service for hostname.local discovery
  # This configuration will override the initial image settings
  services.avahi = {
    enable = true;
    nssmdns = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
  };

  imports = [
    # External modules
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
    
    # Hardware configuration
    (configLib.moduleImport "network/default.nix")
    ./hardware
    
    # System configuration - use minimal profile
    (configLib.profileImport "core/minimal.nix")
    
    # Additional services
    (configLib.moduleImport "services/ssh.nix")
    (configLib.moduleImport "services/gpsd.nix")
    (configLib.moduleImport "services/chrony.nix")
    (configLib.moduleImport "services/gps-ntp-tools.nix")
    (configLib.moduleImport "hardware/rpi-optimizations.nix")
    
    # Security configuration
    ./security.nix
    
    # User configuration
    (configLib.moduleImport "users/gabehoban.nix")
  ];

  # Home-manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit configLib;
    };
  };
  
  age.rekey.hostPubkey = "/etc/ssh/ssh_host_ed25519_key.pub";
  
  # Enable Raspberry Pi firmware with specific configuration
  hardware.enableRedistributableFirmware = true;
  
  # Explicitly disable WiFi
  networking.wireless.enable = false;
  
  # Enable GPS time synchronization with chrony
  services.chrony.enableGPS = true;
  
  # Enable GPS and NTP tools
  services.gpsNtpTools.enable = true;
  
  # Use Raspberry Pi optimizations module for SD card write reduction
  hardware.raspberry-pi = {
    # Enable device tree support
    "4".apply-overlays-dtmerge.enable = true;
    
    # SD card and power optimizations
    optimizeForSD = true;
    enableZramSwap = true;
    volatileLogs = true;
    enablePowerSaving = true;
  };
  
  # TRIM is handled by optimizeForSD setting
  
  # Persistence configuration for important data
  fileSystems."/persist" = {
    device = "/dev/disk/by-label/NIXOS_DATA";
    fsType = "ext4";
    options = [ "noatime" ];
    neededForBoot = true;
  };
  
  environment.persistence."/persist" = {
    directories = [
      "/etc/ssh"
      "/var/lib/chrony"
      "/var/lib/gpsd"
      "/var/lib/NetworkManager"
    ];
  };
}