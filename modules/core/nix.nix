# modules/core/nix.nix
#
# Enhanced Nix package manager configuration with modern features
# Controls Nix behavior, optimization, and package settings
{
  config,
  inputs,
  outputs,
  lib,
  pkgs,
  ...
}:

with lib;

let
  # Nix build optimization settings
  buildSettings = {
    cores = 0; # Use all available cores (0 = auto)
    maxJobs = "auto"; # Automatic job count based on cores
    useNetworkFileSystem = false; # Set to true if using NFS builds
  };

  # Common library paths for nix-ld (dynamic linker)
  commonLibs = with pkgs; [
    # Standard C libraries
    stdenv.cc.cc.lib

    # Common libraries needed by many applications
    zlib
    glib
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    libGL

    # Audio libraries
    alsa-lib
    pulseaudio

    # Crypto
    openssl

    # Graphics/UI libraries
    gtk3
    pango
    cairo
    freetype

    # Database libraries
    sqlite

    # Additional dependencies for common apps
    icu
    curl
    expat
  ];
in
{
  #
  # Nix-ld configuration for running unpackaged binaries
  #
  programs.nix-ld = {
    enable = true;
    # Common libraries needed by many unpackaged programs
    libraries = commonLibs;
  };

  #
  # Nix package manager settings with modern features
  #
  nix = {
    # Use the new nix command and flakes
    extraOptions = ''
      # Enable flake support in legacy nix-* commands
      flake-registry = https://raw.githubusercontent.com/NixOS/flake-registry/master/flake-registry.json

      # Improve nix store disk usage and builds
      builders-use-substitutes = true

      # Download in parallel to improve fetch speed (max number of download processes)
      http-connections = 50

      # Store optimization settings
      narinfo-cache-negative-ttl = 30
      narinfo-cache-positive-ttl = 60
    '';

    # Advanced settings
    settings = {
      #
      # Performance settings
      #
      # Faster connection timeouts
      connect-timeout = 5;
      # Show more log context
      log-lines = 30;
      # 256MB min free space
      min-free = 256000000;
      # 2GB max free space before GC
      max-free = 2000000000;

      # Build optimization settings
      cores = buildSettings.cores;
      max-jobs = buildSettings.maxJobs;
      use-xdg-base-directories = true;

      # Store deduplication and optimization
      auto-optimise-store = true;

      # Newer experimental features beyond basic flakes
      experimental-features = [
        "nix-command" # New nix CLI commands
        "flakes" # Flake support
        "ca-derivations" # Content-addressed derivations
        "cgroups" # Use cgroups for build isolation
        "auto-allocate-uids" # Automatic UID allocation for builds
      ];

      # Keep build logs
      keep-build-log = true;

      # Don't warn on dirty git state
      warn-dirty = false;

      # Required by Cachix to be used as non-root user
      trusted-users = [
        "root"
        "gabehoban"
        "@wheel" # All users in wheel group can manage Nix
      ];

      # Keep build derivations and outputs
      keep-derivations = true;
      keep-outputs = true;

      #
      # Binary cache configuration with improved reuse
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

      # Use fallback (when substitutes fail, build locally)
      fallback = true;

      # Show build stats for substitutes
      print-missing = true;
    };

    #
    # Improved garbage collection with generation tracking
    #
    gc = {
      automatic = true;
      dates = "weekly"; # Run weekly
      options = "--delete-older-than 14d"; # Keep last 14 days
      persistent = true; # Persistent timer (boot catch-up)
      randomizedDelaySec = "45min"; # Randomize to avoid network congestion
    };

    # Automatic optimization
    optimise = {
      automatic = true;
      dates = [ "03:00" ]; # Run at 3AM
    };
  };

  #
  # Nixpkgs configuration with modern features
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
      allowBroken = false; # Changed to false for stability
      # Enable all available hardware support
      enableAllTerminfo = true;
      # Allow system-specific optimizations
      allowLocalBuilds = true;
    };
  };

  # Modern build support tools for better development experience
  environment.systemPackages = with pkgs; [
    nix-index # File index for installed packages
    nix-diff # Compare Nix derivations
    nix-tree # Visualize Nix store paths
    nix-top # Like 'top' for Nix builds
    nix-output-monitor # Better output for nix builds
  ];

  # Optimize Nix storage using automatic compaction
  system.activationScripts.nix-store-optimise = ''
    echo "Optimizing nix store..."
    ${pkgs.nix}/bin/nix-store --optimize
  '';

  # Assertions to check correct configuration
  assertions = [
    {
      assertion = config.nix.settings.trusted-substituters != [ ];
      message = "No trusted substituters configured, builds may be slow without binary caches.";
    }
    {
      assertion = config.nix.settings.trusted-public-keys != [ ];
      message = "No trusted public keys configured for binary cache verification.";
    }
    {
      assertion =
        !(config.nix.settings ? auto-optimise-store) || config.nix.settings.auto-optimise-store
        -> config.nix.optimise.automatic;
      message = "auto-optimise-store is enabled but nix.optimise.automatic is not, which may cause inconsistencies.";
    }
  ];
}
