{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
{
  imports = [
    # Basic hardware detection
    (modulesPath + "/installer/scan/not-detected.nix")
    # Raspberry Pi hardware support
    inputs.hardware.nixosModules.raspberry-pi-4
    # Raspberry Pi specific config
    ./rpi-config.nix
  ];

  # System identification defined in default.nix
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # Boot configuration for Raspberry Pi
  boot = {
    loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
    consoleLogLevel = lib.mkDefault 7;
    
    initrd.availableKernelModules = [
      "xhci_pci"     # USB 3.0 controller
      "usbhid"       # USB HID devices
      "usb_storage"  # USB storage
      "vc4"          # VideoCore GPU
      "bcm2835_dma"  # Broadcom DMA controller
    ];
    # Explicitly load PPS GPIO module for precise timing
    kernelModules = [ "pps_gpio" ];
    extraModulePackages = [ ];
    # Main kernel parameters are consolidated in rpi-config.nix
    kernelParams = [];
  };

  # File systems configuration
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };
  };

  # Hardware-specific settings are now consolidated in rpi-config.nix
  
  # Configure additional GPIO/WiFi settings in boot.extraConfig through extraModprobeConfig
  boot.extraModprobeConfig = ''
    # Disable onboard WiFi
    blacklist brcmfmac
    blacklist brcmutil
    
    # Disable onboard Bluetooth
    blacklist btbcm
    blacklist hci_uart
  '';
  
  # Additional kernel parameters are set above
  
  # Audio is disabled by default
  
  # Explicitly disable serial console on UART0 (ttyAMA0/ttyS0)
  # This is critical to free up the UART for GPS
  services.getty.autologinUser = null;
  # Disable both serial consoles to ensure the GPS has exclusive access
  systemd.services."serial-getty@ttyAMA0".enable = false;
  systemd.services."serial-getty@ttyS0".enable = false;
  
  # Network configuration
  networking.useDHCP = lib.mkDefault true;

  # Hardware firmware support is enabled in the host config
  hardware.i2c.enable = true;
  
  # GPU acceleration settings are handled by raspberry-pi-4 module
}