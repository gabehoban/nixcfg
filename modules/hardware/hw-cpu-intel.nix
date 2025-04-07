# modules/hardware/hw-cpu-intel.nix
#
# Intel CPU configuration and optimizations
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable Intel microcode updates if redistributable firmware is enabled
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Enable performance CPU governor for maximum throughput
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  # Enable thermald for better temperature management
  services.thermald.enable = true;

  # Add hardware monitoring tools
  environment.systemPackages = with pkgs; [
    intel-gpu-tools
    i7z
  ];

  # Setup CPU performance profile for Intel CPUs
  boot.kernelParams = [
    # Enable Intel P-State driver for better power management
    "intel_pstate=active"
    # Modern Intel CPU performance optimization
    "intel_iommu=on"
  ];

  # Load kernel modules for Intel hardware monitoring
  boot.kernelModules = [
    "coretemp" # CPU temperature monitoring
    "kvm-intel" # KVM virtualization support
  ];
}
