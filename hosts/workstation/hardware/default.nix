# ───────────────────────────────────────────
# Hardware Configuration for Workstation
# ───────────────────────────────────────────
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    # Import NixOS hardware detection module for auto-detected hardware
    (modulesPath + "/installer/scan/not-detected.nix")
    # Import ZFS-based storage configuration
    ./disks
    # Import driver for 2.5G Realtek NIC
    ./network/realtek-r8125.nix
  ];

  # ───────────────────────────────────────────
  # System Identification
  # ───────────────────────────────────────────
  # ZFS requires a unique host ID for proper operation
  networking.hostId = "e5af62b5";
  # Target architecture - explicitly set to ensure correct builds
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # ───────────────────────────────────────────
  # Boot Configuration
  # ───────────────────────────────────────────
  boot = {
    # Early boot modules needed to access storage and peripherals
    initrd.availableKernelModules = [
      "nvme"     # Required for NVMe SSD support
      "xhci_pci" # Required for USB 3.x ports
      "ahci"     # Required for SATA drives
      "usbhid"   # Required for USB input devices during early boot
      "sd_mod"   # Support for SD cards if needed
    ];
    
    # No extra initrd modules needed
    initrd.kernelModules = [ ];
    
    # Load KVM module for AMD virtualization support
    kernelModules = [ "kvm-amd" ]; 
    
    # No extra out-of-tree kernel modules needed
    extraModulePackages = [ ];

    # ZFS support for the root filesystem
    supportedFilesystems = [ "zfs" ];
    # Prompt for encryption passphrase during boot
    zfs.requestEncryptionCredentials = true;

    # Implement filesystem immutability via ZFS rollback on every boot
    # This creates a stateless NixOS system where all changes outside
    # of persistent directories are reverted on reboot
    initrd.systemd.services.rollback = {
      description = "Rollback root filesystem to a pristine state on boot";
      wantedBy = [ "initrd.target" ];
      after = [ "zfs-import-zroot.service" ];
      before = [ "sysroot.mount" ];
      path = with pkgs; [ zfs ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        zfs rollback -r zroot/encrypted/root@blank && echo "  >> >> rollback complete << <<"
      '';
    };
  };

  # ───────────────────────────────────────────
  # Network Configuration
  # ───────────────────────────────────────────
  # Enable DHCP by default on all interfaces
  # NetworkManager will manage specific interface configuration
  networking.useDHCP = lib.mkDefault true;
  
  # Previous interfaces kept as reference for future network configs
  # These are commented out as NetworkManager handles them dynamically
  # networking.interfaces.docker0.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.virbr0.useDHCP = lib.mkDefault true;
  # networking.interfaces.ztwfukvlow.useDHCP = lib.mkDefault true;

  # ───────────────────────────────────────────
  # CPU Configuration
  # ───────────────────────────────────────────
  # Enable AMD microcode updates for security and stability
  # Only enabled when redistributable firmware is allowed
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
