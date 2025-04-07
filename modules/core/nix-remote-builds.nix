# modules/core/nix-remote-builds.nix
#
# Configure Nix distributed build capability
_:

{
  # Enable distributed builds
  nix = {
    distributedBuilds = true;

    # Configure default build machines (nuc-titan)
    buildMachines = [
      {
        hostName = "nuc-titan";
        sshUser = "nix-builder";
        sshKey = "/home/gabehoban/.ssh/id_ed25519";
        system = "x86_64-linux";
        maxJobs = 16;
        speedFactor = 2;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }
    ];

    # Settings for remote builds
    settings = {
      trusted-substituters = [
        "https://cache.nixos.org"
        # "https://cache.labrats.cc"  # DISABLED: Public Cloudflare tunnel URL
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        # "labrats.cc:${builtins.readFile /run/agenix/attic-signing-key}"  # DISABLED: For custom binary cache
      ];

      # For better support of remote builders
      builders-use-substitutes = true;

      # Auto-connect to remote builders
      max-jobs = "auto";
    };

    # Add extra options for better remote build support
    extraOptions = ''
      # Keep build derivations and outputs
      keep-derivations = true
      keep-outputs = true

      # Avoid copying unnecessary paths to/from remote builders
      builders-use-substitutes = true
    '';
  };

  # Ensure SSH client is configured properly for remote builds
  programs.ssh = {
    # Don't delay connections
    extraConfig = ''
      ControlMaster auto
      ControlPath ~/.ssh/control-%C
      ControlPersist 1h
      ServerAliveInterval 30
      ServerAliveCountMax 6
    '';

    # Allow host key checking to be bypassed for build hosts
    knownHosts = {
      "nuc-titan".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHS4kNs+yGJ8xt5XHYDCvjP8wUSF473NDMfFXi3Ickm8";
    };
  };

  # System-wide SSH configuration
  systemd.services.nix-daemon = {
    # Ensure SSH authentication works for the Nix daemon
    environment = {
      SSH_AUTH_SOCK = "/run/ssh-agent.sock";
    };
  };

  # Add the attic-signing-key to secrets - DISABLED until binary cache is set up
  # age.secrets.attic-signing-key = {
  #   file = ../../secrets/attic-signing-key.age;
  #   path = "/run/agenix/attic-signing-key";
  #   mode = "0400";
  # };
}
