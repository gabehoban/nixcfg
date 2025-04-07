# hosts/nuc-titan/builder-setup.nix
#
# Setup for Nix remote builder functionality
{
  pkgs,
  ...
}:

{
  # Ensure nix-builder user exists with proper configuration
  users.users.nix-builder = {
    isNormalUser = true;
    home = "/home/nix-builder";
    description = "Nix remote builder user";
    group = "users";
    extraGroups = [
      "wheel"
      "systemd-journal"
    ];

    # Setup SSH for automated remote building
    openssh.authorizedKeys.keys = [
      # The following key should be replaced during installation
      # with the actual build host's public key
      "## REPLACE_WITH_BUILD_KEY ##"
    ];
  };

  # Setup SSH authorized keys directory for easier management
  systemd.tmpfiles.rules = [
    "d /home/nix-builder/.ssh 0700 nix-builder users - -"
    "f /home/nix-builder/.ssh/authorized_keys 0600 nix-builder users - -"
  ];

  # Utility script to add builder keys
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "add-builder-key" ''
      #!/bin/bash
      # Utility script to add a builder public key to nix-builder user
      if [ $# -ne 1 ]; then
        echo "Usage: add-builder-key <public-key-file>"
        exit 1
      fi

      if [ ! -f "$1" ]; then
        echo "Error: Public key file $1 not found"
        exit 1
      fi

      # Add key to authorized_keys
      cat "$1" >> /home/nix-builder/.ssh/authorized_keys
      chmod 600 /home/nix-builder/.ssh/authorized_keys
      chown nix-builder:users /home/nix-builder/.ssh/authorized_keys

      echo "Builder key added successfully"
    '')
  ];

  # Note: Persistence for nix-builder is configured in profiles/server/build-host.nix
}
