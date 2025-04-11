# modules/core/boot.nix
#
# Boot and kernel configuration module
{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  # Import secure boot module
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  # Boot configuration
  boot = {
    # Use systemd in initrd
    initrd.systemd.enable = true;

    # Secure boot with lanzaboote
    lanzaboote = {
      enable = true;
      pkiBundle = lib.mkDefault "/var/lib/sbctl";
    };

    # Boot loader settings
    loader = {
      efi.canTouchEfiVariables = true;
      # Disabled in favor of lanzaboote
      systemd-boot.enable = lib.mkForce false;
      systemd-boot.configurationLimit = 3;
      timeout = 3;
    };

    # Quiet boot settings
    consoleLogLevel = 0;
    initrd.verbose = false;

    # Graphical boot splash
    plymouth = {
      enable = true;
    };
  };

  # Boot-related utility packages
  environment.systemPackages = with pkgs; [
    sbctl # Secure boot key management
    efibootmgr # EFI boot entry management
  ];
}
