# modules/core/impermanence.nix
#
# Persistent storage configuration for ephemeral NixOS systems
# This flattened module configures impermanence for persistent state management
{
  inputs,
  config,
  lib,
  ...
}:

let
  # Access existing values if they exist, or use defaults
  enabled = config.impermanence.enable or false;

  # Access user-defined directories and files to persist
  extraDirs = config.impermanence.directories or [ ];
  extraFiles = config.impermanence.files or [ ];
  userConfigs = config.impermanence.users or { };
in
{
  # Import the upstream module
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  # Define options for customization in host configurations
  options.impermanence = with lib; {
    # Enable/disable impermanence
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable impermanence for ephemeral state management";
    };

    # System-level directories
    directories = mkOption {
      default = [ ];
      description = "List of system directories to make persistent";
    };

    # System-level files
    files = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of system files to make persistent";
    };

    # User-specific configuration
    users = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            directories = mkOption {
              type = types.listOf (
                types.either types.str (
                  types.submodule {
                    options = {
                      directory = mkOption {
                        type = types.str;
                        description = "Path to directory";
                      };
                      mode = mkOption {
                        type = types.str;
                        description = "Permissions mode";
                      };
                    };
                  }
                )
              );
              default = [ ];
              description = "User directories to make persistent";
            };
            files = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "User files to make persistent";
            };
          };
        }
      );
      default = { };
      description = "Per-user persistence configuration";
    };
  };

  # Direct implementation
  config = lib.mkIf enabled {
    # Create home directory persistence links for each user
    system.activationScripts.persistent-dirs.text =
      let
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

    # Configure persistent storage
    environment.persistence."/persist" = {
      # Hide bind mounts from user tools
      hideMounts = true;

      # System-level directories to persist
      directories = [
        # Network configuration - only connection profiles
        "/etc/NetworkManager/system-connections"
        # Secure boot key management
        "/var/lib/sbctl"
        # Systemd state (logs, timers, etc.)
        "/var/lib/systemd"
        # NixOS state
        "/var/lib/nixos"
        # Note: /etc/nixos removed as it's managed by the NixOS system itself
      ] ++ extraDirs;

      # System-level files to persist
      files = [
        # Stable machine identifier
        "/etc/machine-id"
        # SSH host key
        "/etc/ssh/ssh_host_ed25519_key"
        # SSH host public key
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ] ++ extraFiles;

      # User-specific files and directories to persist
      users = lib.mapAttrs (username: userCfg: {
        directories =
          # Default directories for the primary user
          (
            if username == "gabehoban" then
              [
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
              ]
            else
              [ ]
          )
          ++ userCfg.directories;

        # Include user-specific files
        inherit (userCfg) files;
      }) userConfigs;
    };
  };
}
