# hosts/sekio/default.nix
#
# Main configuration for the Sekio host (Raspberry Pi 4 with GPS)
{
  configLib,
  inputs,
  ...
}:
{
  networking.hostName = "sekio";
  networking.hostId = "a7b92c14";

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

    # Services
    (configLib.moduleImport "services/ssh.nix")
    (configLib.moduleImport "services/gpsd.nix")
    (configLib.moduleImport "services/chrony.nix")
    (configLib.moduleImport "services/gps-ntp-tools.nix")

    # Host-specific configurations
    ./security.nix
    ./optimization.nix

    # User configuration
    (configLib.moduleImport "users/gabehoban.nix")
  ];

  # Home-manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit configLib;
    };
  };

  # SSH host key for age encryption
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAIaE/fnTZFlw/JxvSzW23PCi7gO0yFWDwurCyxVUr3O";

  # Enable Raspberry Pi firmware
  hardware.enableRedistributableFirmware = true;

  # Enable GPS time synchronization with chrony
  services.chrony.enableGPS = true;

  # Enable device tree support
  hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;

  # Enable impermanence for ephemeral system state
  impermanence.enable = false;

  # NixOS release version
  system.stateVersion = "24.11";
}
