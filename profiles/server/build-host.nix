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
  # Create build user
  users.users.nix-builder = {
    isNormalUser = true;
    home = "/home/nix-builder";
    description = "Nix remote builder user";
    group = "users";
    uid = 1001;
    extraGroups = [
      "wheel"
      "systemd-journal"
    ];
    openssh.authorizedKeys.keyFiles = [
      # Add build keys here
    ];
  };

  # Ensure proper persistence for build operations
  # Note: /nix and /var/log are already handled by dedicated ZFS datasets
  # No additional system directories needed for impermanence

  # Ensure nix-builder's SSH directory is persistent
  impermanence.users = {
    "nix-builder" = {
      directories = [ ".ssh" ];
    };
  };

  # ───────────────────────────────────────────
  # Build optimization
  # ───────────────────────────────────────────
  # Configure higher limits for builders
  security.pam.loginLimits = [
    {
      domain = "nix-builder";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "nix-builder";
      type = "hard";
      item = "nofile";
      value = "65536";
    }
  ];

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
