{config, ...}: {
  boot.extraModulePackages = [
    (config.boot.kernelPackages.callPackage ./kernel-module.nix {})
  ];
  boot.blacklistedKernelModules = ["r8169"];
}


{config, packages, ...}:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-kde.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.r8168 ];
  boot.blacklistedKernelModules = ["r8169"];
  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
}
