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
    # Basic hardware detection
    (modulesPath + "/installer/scan/not-detected.nix")
    # Storage configuration
    ./disks
    # Network hardware drivers
    ./network/realtek-r8125.nix
  ];

  # ───────────────────────────────────────────
  # System Identification
  # ───────────────────────────────────────────
  networking.hostId = "e5af62b5";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # ───────────────────────────────────────────
  # Boot Configuration
  # ───────────────────────────────────────────
  boot = {
    # Kernel modules
    initrd.availableKernelModules = [
      "nvme" # NVMe SSD support
      "xhci_pci" # USB 3.0 controller
      "ahci" # SATA controller
      "usbhid" # USB HID devices
      "sd_mod" # SD card support
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" ]; # KVM virtualization for AMD
    extraModulePackages = [ ];

    # Filesystem support
    supportedFilesystems = [ "zfs" ];
    zfs.requestEncryptionCredentials = true;

    # Root filesystem rollback on boot
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
  networking.useDHCP = lib.mkDefault true;
  # Commented interfaces kept for reference
  # networking.interfaces.docker0.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.virbr0.useDHCP = lib.mkDefault true;
  # networking.interfaces.ztwfukvlow.useDHCP = lib.mkDefault true;

  # ───────────────────────────────────────────
  # CPU Configuration
  # ───────────────────────────────────────────
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
