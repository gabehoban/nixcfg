# modules/users/gabehoban.nix
#
# User configuration for gabehoban
_: {
  #
  # User account configuration
  #
  users = {
    users = {
      # Primary user account
      gabehoban = {
        isNormalUser = true;
        description = "Gabe Hoban";

        # Group membership for various system capabilities
        extraGroups = [
          "networkmanager" # Network management
          "wheel" # Administrative access
          "media" # Media files access
          "input" # Input devices access
          "libvirt" # Virtualization
          "audio" # Audio devices
          "video" # Video devices
          "power" # Power management
          "users" # Standard user group
          "kvm" # KVM virtualization
        ];

        # Password hash for login
        hashedPassword = "$7$CU..../....6H2Cxu.oYQY6HBpWe1OSG/$RnZAJioALqERJR6zUbApQWFbVWpmJNi4S/eo5KYM.G5";

        # SSH configuration
        openssh = {
          # Authorized keys for SSH access
          authorizedKeys.keys = [
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPH/GNUI0con3U+Jmh7tYAnvGTT9bSzkA5kUJAWy0UT8AAAABHNzaDo="
          ];
        };
      };

      # Root account configuration
      root = {
        isNormalUser = false;
        hashedPassword = "$7$CU..../....t306LucALVXUzf9M43FqQ1$Pn2YxX4.TiCK9vaRRst7b6R2xxTeAARC1hxCZ1SBlu1";
      };
    };

    # Additional system groups
    groups = {
      docker = { };
      libvirt = { };
    };
  };

  #
  # Home Manager configuration
  #
  home-manager.users.gabehoban = {
    home.username = "gabehoban";
    home.homeDirectory = "/home/gabehoban";
    home.stateVersion = "24.11";
  };

  #
  # Security configuration
  #
  # Allow sudo without password for wheel group members
  security.sudo.wheelNeedsPassword = false;
}
