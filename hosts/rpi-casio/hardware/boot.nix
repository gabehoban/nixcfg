# hosts/rpi-casio/hardware/boot.nix
#
# Boot configuration for rpi-casio Raspberry Pi
{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  blCfg = config.boot.loader;
  dtCfg = config.hardware.deviceTree;
  cfg = blCfg.generic-extlinux-compatible;
  timeoutStr = if blCfg.timeout == null then "-1" else toString blCfg.timeout;
  builderScript = "${inputs.nixpkgs}/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.sh";
  fixedBuilderScriptName = "extlinux-conf-builder-no-interaction.sh";
  fixedBuilderScript = pkgs.runCommand fixedBuilderScriptName { } ''
    (
    set -x
    ${pkgs.perl}/bin/perl -pe 's/^((?:TIMEOUT|menu).*)$/# $1 # commented to ignore UART input during boot/g' ${builderScript} > $out
    )
  '';
  mkFixedBuilder =
    { pkgs }:
    pkgs.replaceVarsWith {
      src = fixedBuilderScript;
      isExecutable = true;
      replacements = {
        path = lib.makeBinPath [
          pkgs.coreutils
          pkgs.gnused
          pkgs.gnugrep
        ];
        inherit (pkgs) bash;
      };
    };
  fixedBuilder = mkFixedBuilder { inherit pkgs; };
  builderArgs =
    "-g ${toString cfg.configurationLimit} -t ${timeoutStr}"
    + lib.optionalString (dtCfg.name != null) " -n ${dtCfg.name}"
    + lib.optionalString (!cfg.useGenerationDeviceTree) " -r";
in
{
  system.build.installBootLoader = lib.mkForce "${fixedBuilder} ${builderArgs} -c";

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
      generic-extlinux-compatible.configurationLimit = 1;
    };

    # Console log verbosity
    consoleLogLevel = lib.mkDefault 7;

    # Required kernel modules
    initrd.availableKernelModules = [
      "xhci_pci" # USB 3.0 controller
      "usbhid" # USB HID devices
      "usb_storage" # USB storage
      "vc4" # VideoCore GPU
      "bcm2835_dma" # Broadcom DMA controller
    ];

    # Explicitly load PPS GPIO module for precise timing
    kernelModules = [ "pps_gpio" ];

    # No additional kernel modules
    extraModulePackages = [ ];

    # Main kernel parameters are consolidated in rpi-config.nix
    kernelParams = [ ];
  };
}
