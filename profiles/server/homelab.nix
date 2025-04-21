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
  # Common configuration for homelab servers
  # ───────────────────────────────────────────
  # Module Imports
  # ───────────────────────────────────────────
  imports = [
    # External modules
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko

    # Import the minimal core profile
    (configLib.profileImport "core/minimal.nix")

    # Services
    (configLib.moduleImport "services/ssh.nix")
    (configLib.moduleImport "services/tailscale.nix")
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
  networking.firewall.enable = true;

  # ───────────────────────────────────────────
  # System Configuration
  # ───────────────────────────────────────────

  boot.kernelParams = [
    "lockdown=none"
    "init_on_alloc=1" # Initialize heap memory allocations
    "init_on_free=1" # Initialize freed heap memory
    "page_alloc.shuffle=1" # Randomize page allocator freelists
    "pti=on" # Page Table Isolation (Meltdown mitigation)
    "randomize_kstack_offset=on" # Strengthen kernel stack ASLR
    "vsyscall=none" # Disable vsyscall table (legacy feature)
  ];

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
