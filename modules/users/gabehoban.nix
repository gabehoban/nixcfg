# modules/users/gabehoban.nix
#
# User configuration for gabehoban
{ config, ... }:
{
  age.secrets.hashed-root-password.rekeyFile = ../../secrets/hashed-root-password.age;
  age.secrets.hashed-user-password.rekeyFile = ../../secrets/hashed-user-password.age;

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
        hashedPasswordFile = config.age.secrets.hashed-user-password.path;

        # SSH configuration
        openssh = {
          # Authorized keys for SSH access - ensure this key has sudo access for Colmena deployments
          authorizedKeys.keys = [
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPH/GNUI0con3U+Jmh7tYAnvGTT9bSzkA5kUJAWy0UT8AAAABHNzaDo="
          ];
        };
      };

      # Root account configuration
      root = {
        isNormalUser = false;
        hashedPasswordFile = config.age.secrets.hashed-root-password.path;
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
