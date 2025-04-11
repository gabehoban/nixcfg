# profiles/server/gps-ntp.nix
#
# Common profile for Raspberry Pi GPS-based NTP servers
# Extracts shared functionality between rpi-sekio and rpi-casio
{
  configLib,
  inputs,
  pkgs,
  ...
}:
{
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
    (configLib.moduleImport "hardware/hw-platform-rpi.nix")
    (configLib.moduleImport "hardware/hw-gps.nix")

    # Services
    (configLib.moduleImport "services/ssh.nix")
    (configLib.moduleImport "services/gpsd.nix")
    (configLib.moduleImport "services/chrony.nix")
    (configLib.moduleImport "services/gps-ntp-tools.nix")
    (configLib.moduleImport "services/gps-monitoring.nix")
    (configLib.moduleImport "services/tailscale.nix")

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
  networking.firewall.enable = true;

  # ───────────────────────────────────────────
  # System Configuration
  # ───────────────────────────────────────────
  # Persistent storage needed for accurate timekeeping
  impermanence.enable = false;

  # ───────────────────────────────────────────
  # Build environment
  # ───────────────────────────────────────────
  # Essential packages needed for the build process
  environment.systemPackages = with pkgs; [
    cacert
  ];

  # Certificate handling
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];

  system.stateVersion = "24.11";
}
