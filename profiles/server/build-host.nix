# profiles/server/build-host.nix
#
# Profile for dedicated Nix build hosts
{
  configLib,
  pkgs,
  ...
}:
{
  # ───────────────────────────────────────────
  # Module Imports
  # ───────────────────────────────────────────
  imports = [
    # Base homelab profile
    ./homelab.nix

    # Core build modules
    (configLib.moduleImport "core/nix-remote-builds.nix")
  ];

  # ───────────────────────────────────────────
  # Nix Configuration
  # ───────────────────────────────────────────
  nix = {
    # Optimize for build performance
    settings = {
      max-jobs = "auto";
      cores = 0; # Use all cores
      sandbox = true;
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "gabehoban"
        "nix-builder"
      ];
    };

    # Enable flakes
    extraOptions = ''
      experimental-features = nix-command flakes
      # Keep build dependencies around to avoid rebuilding
      keep-derivations = true
      keep-outputs = true
    '';
  };

  # ───────────────────────────────────────────
  # System Configuration
  # ───────────────────────────────────────────

  # Optimize system for builds
  boot.kernel.sysctl = {
    # File system and I/O tuning
    "vm.dirty_ratio" = 60;
    "vm.dirty_background_ratio" = 2;
    # Network tuning
    "net.core.somaxconn" = 4096;
    "net.ipv4.tcp_max_syn_backlog" = 4096;
  };

  # Install build-specific utilities
  environment.systemPackages = with pkgs; [
    ccache
    linuxPackages.perf
    git-lfs
    nix-output-monitor
    nix-tree
  ];
}
