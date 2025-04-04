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
      
      # Use custom U-Boot with auto-boot configuration
      # that ignores UART interrupts during boot
      uboot = {
        enable = true;
        package = pkgs.ubootRaspberryPi4_64bit;
      };
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
    kernelParams = [
      # Use only the display console, not the UART/serial console
      # since the GPS HAT uses these pins
      "console=tty0"
      
      # Disable dynamic ticks for better timing accuracy
      "nohz=off"
    ];
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

  # Hardware-specific settings
  hardware.deviceTree = {
    filter = "bcm2711-rpi-4-*.dtb";
  };
  
  # Configure device tree settings through the standard mechanism
  hardware.raspberry-pi = {
    # Disable onboard WiFi
    dwc2.enable = false;
    
    # Disable onboard Bluetooth
    bluetooth.enable = false;
    
    # Use mini-UART to free up PL011 UART for GPS
    miniUart.enable = true;
  };
  
  # Disable audio
  hardware.raspberry-pi.audio.enable = false;
  
  # Explicitly disable serial console on UART0 (ttyAMA0)
  # This is critical to free up the UART for GPS
  services.getty.autologinUser = null;
  systemd.services."serial-getty@ttyAMA0".enable = false;
  systemd.services."serial-getty@ttyS0".enable = false;
  
  # Network configuration
  networking.useDHCP = lib.mkDefault true;

  # Hardware firmware support is enabled in the host config
  hardware.i2c.enable = true;
  hardware.gpio.enable = true;
  
  # Disable GPU acceleration to save power
  hardware.raspberry-pi."4".fkms-3d.enable = false;
}