# profiles/server/homelab.nix
#
# Common profile for homelab server hosts
# Extracts shared functionality for NUC-based infrastructure
{
  configLib,
  inputs,
  pkgs,
  ...
}:
{
  #TODO: FIX SECRETS
  # ───────────────────────────────────────────
  # Module Imports
  # ───────────────────────────────────────────
  imports = [
    # External modules
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko

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

    # Services
    (configLib.moduleImport "services/ssh.nix")
    (configLib.moduleImport "services/tailscale.nix")
    (configLib.moduleImport "services/monitoring.nix")
    (configLib.moduleImport "services/zram.nix")

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

  # ───────────────────────────────────────────
  # Network and Security Configuration
  # ───────────────────────────────────────────
  modules.network.firewall.enable = true;

  # ───────────────────────────────────────────
  # System Configuration
  # ───────────────────────────────────────────
  # Enable impermanence for homelab servers
  impermanence.enable = true;

  # Ensure media group exists
  users.groups.media.gid = 65542;

  # Common NFS mount for media
  fileSystems."/export/media" = {
    device = "10.32.40.10:/mnt/user/media";
    fsType = "nfs";
    options = [
      "noatime"
      "nofail"
    ];
  };

  # ───────────────────────────────────────────
  # Build environment
  # ───────────────────────────────────────────
  # Essential packages needed for the build process
  environment.systemPackages = with pkgs; [
    cacert
    # Common admin tools
    htop
    iotop
    iftop
    ethtool
    smartmontools
    btrfs-progs
    lsof
    tmux
  ];

  # Certificate handling
  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];

  system.stateVersion = "24.11";
}
