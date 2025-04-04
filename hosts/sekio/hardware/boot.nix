# hosts/sekio/hardware/boot.nix
#
# Boot configuration for Sekio Raspberry Pi
{ lib, ... }:

{
  # Boot configuration for Raspberry Pi
  boot = {
    loader = {
      # Use genericLinux instead of u-boot or extlinux
      grub.enable = false;
      systemd-boot.enable = false;

      # Enable generic Linux compatible boot
      generic-extlinux-compatible.enable = true;

      # Prevent attempting to use EFI variables from firmware
      efi.canTouchEfiVariables = true;
      
      # Keep configuration history limited
      generic-extlinux-compatible.configurationLimit = 3;
    };

    # Console log verbosity
    consoleLogLevel = lib.mkDefault 7;

    # Required kernel modules
    initrd.availableKernelModules = [
      "xhci_pci"      # USB 3.0 controller
      "usbhid"        # USB HID devices
      "usb_storage"   # USB storage
      "vc4"           # VideoCore GPU
      "bcm2835_dma"   # Broadcom DMA controller
    ];
    
    # Explicitly load PPS GPIO module for precise timing
    kernelModules = [ "pps_gpio" ];
    
    # No additional kernel modules
    extraModulePackages = [ ];
    
    # Main kernel parameters are consolidated in rpi-config.nix
    kernelParams = [ ];
  };
}