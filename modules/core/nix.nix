# modules/core/nix.nix
#
# Nix package manager configuration
# Controls Nix behavior, optimization, and package settings
{
  inputs,
  outputs,
  ...
}:
{
  #
  # Nix-ld configuration for running unpackaged binaries
  #
  programs.nix-ld = {
    enable = true;
    # Add any missing dynamic libraries for unpackaged programs here, NOT in environment.systemPackages
    libraries = [
    ];
  };

  #
  # Nix package manager settings
  #
  nix = {
    settings = {
      #
      # Performance settings
      # See https://jackson.dev/post/nix-reasonable-defaults/
      #
      # Faster connection timeouts
      connect-timeout = 5;
      # Show more log context
      log-lines = 25;
      # 128MB min free space
      min-free = 128000000;
      # 1GB max free space before GC
      max-free = 1000000000;

      # Deduplicate and optimize nix store
      auto-optimise-store = true;

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

      #
      # Binary cache configuration
      #
      # Binary caches for faster builds
      trusted-substituters = [
        "https://cache.nixos.org/"
        "https://gabehoban.cachix.org"
        "https://chaotic-nyx.cachix.org"
        "https://nix-community.cachix.org"
      ];

      # Public keys for binary caches
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "gabehoban.cachix.org-1:8KJ3WRVyJGR7/Ghf1qol4pCqmmGuxNNpedDneyivky4="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    #
    # Garbage collection settings
    #
    gc = {
      automatic = true;
      # Keep last 10 days
      options = "--delete-older-than 10d";
    };
  };

  #
  # Nixpkgs configuration
  #
  nixpkgs = {
    # Apply custom overlays
    overlays = [
      inputs.agenix-rekey.overlays.default
      outputs.overlays.additions
    ];

    # Package availability settings
    config = {
      # Allow proprietary packages
      allowUnfree = true;
      # Allow packages marked as broken
      allowBroken = true;
    };
  };
}
