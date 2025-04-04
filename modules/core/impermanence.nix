# modules/core/impermanence.nix
#
# Persistent storage configuration for ephemeral NixOS systems
{
  inputs,
  config,
  lib,
  ...
}:

with lib;

let
  # Create a new option for collecting persistence configuration
  cfg = config.impermanence;
in {
  #
  # Module imports - always import the upstream module
  #
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  #
  # Define options for collecting persistence information 
  # This allows modules to safely declare persistence without errors
  # when the impermanence module is not imported
  #
  options.impermanence = {
    # Enable/disable impermanence
    enable = mkEnableOption "impermanence for ephemeral state management";
    
    # System-level directories
    directories = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of system directories to make persistent";
    };

    # System-level files
    files = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of system files to make persistent";
    };

    # User-specific configuration
    users = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          directories = mkOption {
            type = types.listOf (types.either types.str (types.submodule {
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
            }));
            default = [];
            description = "User directories to make persistent";
          };
          files = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "User files to make persistent";
          };
        };
      });
      default = {};
      description = "Per-user persistence configuration";
    };
  };

  # Apply configuration based on collected options
  config = {
    # Ensure that we're intentionally using impermanence
    assertions = [
      {
        assertion = !lib.hasAttr "environment" config || 
                   !lib.hasAttr "persistence" config.environment ||
                   !lib.pathExists "/persist" || 
                   cfg.enable;
        message = "Impermanence features detected but config.impermanence.enable is not set. Set impermanence.enable = true if intended.";
      }
    ];

    # The rest of the configuration only applies when impermanence is enabled
    system.activationScripts = mkIf cfg.enable {
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
    # Only apply the collected persistence configuration if enabled and
    # environment.persistence is available (impermanence is imported)
    environment.persistence = mkIf (cfg.enable && config ? environment.persistence) {
      "/persist" = {
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
        ] ++ cfg.directories;

        # System-level files to persist
        files = [
          # Stable machine identifier
          "/etc/machine-id"
          # SSH host key
          "/etc/ssh/ssh_host_ed25519_key"
          # SSH host public key
          "/etc/ssh/ssh_host_ed25519_key.pub"
        ] ++ cfg.files;

        # User-specific files and directories to persist
        users = mapAttrs (username: userCfg: {
          directories = 
            # Default directories for the primary user
            (if username == "gabehoban" then [
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
            ] else []) ++ userCfg.directories;
          
          # Include user-specific files
          files = userCfg.files;
        }) cfg.users;
      };
    };
  };
}