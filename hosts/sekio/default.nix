# hosts/sekio/default.nix
#
# Stratum 1 NTP server using GPS for timing (Raspberry Pi 4)
{
  configLib,
  inputs,
  lib,
  ...
}:
{
  networking = {
    hostName = "sekio";
    hostId = "a7b92c14";
  };

  # ───────────────────────────────────────────
  # Module Imports
  # ───────────────────────────────────────────
  imports = [
    # External modules
    inputs.home-manager.nixosModules.home-manager

    # Core system modules
    (configLib.moduleImport "network/default.nix")
    (configLib.moduleImport "core/git.nix")
    (configLib.moduleImport "core/locale.nix")
    (configLib.moduleImport "core/nix.nix")
    (configLib.moduleImport "core/impermanence.nix")
    (configLib.moduleImport "core/packages.nix")
    (configLib.moduleImport "core/secrets.nix")
    (configLib.moduleImport "core/starship.nix")
    (configLib.moduleImport "core/zsh.nix")

    # Hardware
    ./hardware
    (configLib.moduleImport "hardware/hw-platform-rpi.nix")
    (configLib.moduleImport "hardware/hw-gps.nix")

    # Services
    (configLib.moduleImport "services/ssh.nix")
    (configLib.moduleImport "services/gpsd.nix")
    (configLib.moduleImport "services/chrony.nix")
    (configLib.moduleImport "services/gps-ntp-tools.nix")
    (configLib.moduleImport "services/gps-monitoring.nix")

    # Host-specific configurations
    ./security.nix
    ./optimization.nix

    # User configuration
    (configLib.moduleImport "users/gabehoban.nix")
  ];

  # ───────────────────────────────────────────
  # Home-Manager Configuration
  # ───────────────────────────────────────────
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit configLib;
    };
  };

  # ───────────────────────────────────────────
  # Security Settings
  # ───────────────────────────────────────────
  # SSH host key for age encryption
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJco2ctNIBP1fph74SCE6LMv8oKF1PYjRupAmbC6pdd3";

  # ───────────────────────────────────────────
  # Hardware Configuration
  # ───────────────────────────────────────────
  hardware.enableRedistributableFirmware = true;
  hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;

  # ───────────────────────────────────────────
  # Service Configuration
  # ───────────────────────────────────────────
  # Enable GPS time synchronization
  services.chrony.enableGPS = true;

  # ───────────────────────────────────────────
  # Network and Security Configuration
  # ───────────────────────────────────────────
  modules.network.firewall.enable = true;

  # ───────────────────────────────────────────
  # System Configuration
  # ───────────────────────────────────────────
  # Persistent storage needed for accurate timekeeping
  impermanence.enable = false;

  system.stateVersion = "24.11";
}