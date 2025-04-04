# Workstation ISO image definition
# To build: nix build .#images.workstation-iso.config.system.build.isoImage
{ config, pkgs, ... }:
{
  # Set installation image settings
  isoImage.edition = "Workstation";
  isoImage.appendToMenuLabel = " Installer";

  # Enable Realtek r8125 network module
  boot.extraModulePackages = [
    (config.boot.kernelPackages.callPackage
      ../hosts/workstation/hardware/network/realtek-r8125-module.nix
      { }
    )
  ];
  boot.blacklistedKernelModules = [ "r8169" ];

  # Enable Yubikey for secrets decryption
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # Customize installer environment
  environment.systemPackages = with pkgs; [
    gparted
    vim
    git
    htop
  ];

  # Set default hostname
  networking.hostName = "workstation-installer";
}
