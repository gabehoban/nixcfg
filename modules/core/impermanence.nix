# modules/core/impermanence.nix
#
# Persistent storage configuration for ephemeral NixOS systems
{
  inputs,
  config,
  lib,
  ...
}:
{
  #
  # Module imports
  #
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  #
  # Persistent directory creation
  #
  system.activationScripts = {
    persistent-dirs.text =
      let
        # Create home directory persistence links for each user
        mkHomePersist =
          user:
          lib.optionalString user.createHome ''
            mkdir -p /persist/${user.home}
            chown ${user.name}:${user.group} /persist/${user.home}
            chmod ${user.homeMode} /persist/${user.home}
          '';
        users = lib.attrValues config.users.users;
      in
      lib.concatLines (map mkHomePersist users);
  };

  #
  # Persistent file and directory configuration
  #
  environment.persistence."/persist" = {
    # Hide bind mounts from user tools
    hideMounts = true;

    # System-level directories to persist
    directories = [
      # Network configuration
      "/etc/NetworkManager"
      # NixOS configuration
      "/etc/nixos"
      # NixOS state
      "/var/lib/nixos"
      # Secure boot key management
      "/var/lib/sbctl"
      # Systemd state (logs, timers, etc.)
      "/var/lib/systemd"
    ];

    # System-level files to persist
    files = [
      # Stable machine identifier
      "/etc/machine-id"
      # SSH host key
      "/etc/ssh/ssh_host_ed25519_key"
      # SSH host public key
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];

    # User-specific files and directories to persist
    users.gabehoban = {
      directories = [
        # XDG user directories
        "Desktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Videos"
        # More directories
        # Git repositories
        "repos"
        # SSH keys and configuration
        ".ssh"
      ];
    };
  };
}
