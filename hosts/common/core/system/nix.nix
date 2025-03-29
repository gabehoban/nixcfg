# Nix package manager configuration
# Controls Nix behavior, optimization, and package settings
{
  outputs,
  pkgs,
  ...
}:
{
  # Enable nix-ld for running unpackaged binaries
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged programs
      # here, NOT in environment.systemPackages
    ];
  };

  # Nix package manager configuration
  nix = {
    settings = {
      # Performance settings
      # See https://jackson.dev/post/nix-reasonable-defaults/
      connect-timeout = 5; # Faster connection timeouts
      log-lines = 25; # Show more log context
      min-free = 128000000; # 128MB min free space
      max-free = 1000000000; # 1GB max free space before GC

      # Store optimization
      auto-optimise-store = true; # Deduplicate and optimize nix store

      # Required by Cachix to be used as non-root user
      trusted-users = [
        "root"
        "gabehoban"
      ];

      # Enable flakes and new CLI commands
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Don't warn on dirty git state
      warn-dirty = false;

      # Binary caches for faster builds
      trusted-substituters = [
        "https://cache.garnix.io"
        "https://cache.nixos.org/"
        "https://chaotic-nyx.cachix.org"
        "https://nix-community.cachix.org"
      ];

      # Public keys for binary caches
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    # Automatic garbage collection
    gc = {
      automatic = true;
      options = "--delete-older-than 10d"; # Keep last 10 days
    };
  };

  # Nixpkgs configuration
  nixpkgs = {
    # Apply custom overlays
    overlays = [
      outputs.overlays.additions
    ];

    # Package availability settings
    config = {
      allowUnfree = true; # Allow proprietary packages
      allowBroken = true; # Allow packages marked as broken
    };
  };
}
