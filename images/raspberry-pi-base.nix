# images/raspberry-pi-base.nix
#
# Common base for all Raspberry Pi images
# This provides the core functionality for building SD images for Raspberry Pi devices
{
  config,
  configLib,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  blCfg = config.boot.loader;
  dtCfg = config.hardware.deviceTree;
  cfg = blCfg.generic-extlinux-compatible;
  timeoutStr = if blCfg.timeout == null then "-1" else toString blCfg.timeout;
  builderScript = "${inputs.nixpkgs}/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.sh";
  fixedBuilderScriptName = "extlinux-conf-builder-no-interaction.sh";
  # Create a modified U-Boot builder script that ignores UART input
  # This is critical for GPS module compatibility since the GPS sends data on the UART
  # that would otherwise interfere with the bootloader menu
  fixedBuilderScript = pkgs.runCommand fixedBuilderScriptName { } ''
    (
    set -x
    # Modify the script to comment out TIMEOUT and menu lines that wait for input
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
  fixedPopulateBuilder = mkFixedBuilder { pkgs = pkgs.buildPackages; };
  builderArgs =
    "-g ${toString cfg.configurationLimit} -t ${timeoutStr}"
    + lib.optionalString (dtCfg.name != null) " -n ${dtCfg.name}"
    + lib.optionalString (!cfg.useGenerationDeviceTree) " -r";
in
{
  imports = [
    # Absolutely minimal config for SD image builder
    # Do not import the full hardware config, as it includes boot.loader.uboot which is not compatible
    inputs.hardware.nixosModules.raspberry-pi-4
    inputs.impermanence.nixosModules.impermanence
    (configLib.moduleImport "core/locale.nix")
    (configLib.moduleImport "services/ssh.nix")
  ];

  # Set system configuration for the image
  system.build.installBootLoader = lib.mkForce "${fixedBuilder} ${builderArgs} -c";
  sdImage.populateRootCommands = lib.mkForce ''
    mkdir -p ./files/boot
    ${fixedPopulateBuilder} ${builderArgs} -c ${config.system.build.toplevel} -d ./files/boot
  '';
  sdImage.compressImage = true;

  # Allow the SD image to expand on first boot to use the full card
  sdImage.expandOnBoot = true;
  # Configure root filesystem for installer image
  fileSystems."/" = lib.mkForce {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
    ];
    autoResize = true; # Allow the root filesystem to expand on first boot
  };

  # Configure basic directories for the installer image
  systemd.tmpfiles.rules = [
    # Ensure required directories exist
    "d /var/lib/chrony 0755 chrony chrony -"
    "d /var/lib/gpsd 0755 root root -"
    "d /var/lib/NetworkManager 0755 root root -"
  ];

  # Enable SSH for remote access (initial setup only)
  services.openssh = {
    enable = true;
    settings = {
      # Allow root login for initial setup only
      PermitRootLogin = lib.mkForce "yes";
      # Allow password authentication for initial setup only
      PasswordAuthentication = lib.mkForce true;
    };
  };

  # Set secure initial password for setup
  # This will be replaced after nixos-rebuild with the host configuration
  users.users.root.initialPassword = "nixos";

  # Configure network for headless access
  networking = {
    wireless.enable = false;
    networkmanager.enable = true;

    # Enable mDNS so the device can be found at hostname.local
    # This is compatible with Avahi/Bonjour
    firewall.allowedUDPPorts = [ 5353 ];
  };

  # Enable mDNS service for hostname.local discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
  };

  # ───────────────────────────────────────────
  # Build environment
  # ───────────────────────────────────────────
  # Essential packages needed for the build process
  environment.systemPackages = with pkgs; [
    # Basic utilities
    vim
    htop
    wget
    git
    usbutils
    pciutils
    
    # Required for persistence partition creation
    parted # For disk management
    e2fsprogs # For filesystem operations
    util-linux # For mount command
    gnused # For text processing
    gptfdisk # For sgdisk command
    
    # Certificates for build process
    cacert
  ];

  # Certificate handling
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
  
  # Name for the image in metadata
  system.stateVersion = "24.11";

  # Disable ZFS for Raspberry Pi
  boot.supportedFilesystems = lib.mkForce [
    "vfat"
    "ext4"
  ];

  # Add specific Raspberry Pi firmware settings that would normally come from the hardware config
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.raspberrypiWirelessFirmware ];

    # Add some basic Raspberry Pi configuration
    raspberry-pi = {
      # Enable device tree support
      "4" = {
        apply-overlays-dtmerge.enable = true;
      };
    };
  };

  # Hardware-specific settings for Raspberry Pi 4 SD image
  boot = {
    # Must use extlinux for SD image initial boot
    loader.efi.canTouchEfiVariables = true;
    loader.generic-extlinux-compatible.enable = lib.mkDefault true;
  };
}