# modules/hardware/hw-cpu-amd.nix
#
# AMD CPU configuration and optimizations
{ config, lib, ... }:

{
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.blacklistedKernelModules = [
    "k10temp"
    "acpi-cpufreq"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.zenpower ];
  boot.kernelModules = [ "zenpower" ];
  boot.kernelParams = [ "amd_pstate=active" ];
}