# modules/hardware/hw-cpu-amd.nix
#
# AMD CPU configuration and optimizations
{
  config,
  lib,
  ...
}:

{
  # Enable AMD microcode updates if redistributable firmware is enabled
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Blacklist default temperature and CPU frequency modules that conflict with zenpower
  boot.blacklistedKernelModules = [
    "k10temp" # Default temperature monitoring module
    "acpi-cpufreq" # Default CPU frequency scaling module
  ];

  # Add zenpower module package for better temperature monitoring on Zen architecture
  boot.extraModulePackages = [ config.boot.kernelPackages.zenpower ];

  # Load zenpower module for better monitoring of AMD Zen processors
  boot.kernelModules = [ "zenpower" ];

  # Enable AMD P-State driver for better power management
  boot.kernelParams = [ "amd_pstate=active" ];
}
