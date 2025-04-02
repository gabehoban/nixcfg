# modules/applications/app-1password.nix
#
# 1Password password manager configuration
{ lib, ... }:
{
  #
  # License and unfree package configuration
  #
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      # Allow unfree 1Password packages
      "1password-gui" # GUI client
      "1password" # CLI client
    ];

  #
  # 1Password client configuration
  #
  # Enable CLI client
  programs._1password.enable = true;

  # Enable GUI client with polkit integration
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "gabehoban" ]; # Grant polkit permissions to user
  };

  #
  # Persistent configuration
  #
  environment.persistence."/persist" = {
    users.gabehoban = {
      directories = [
        # Store 1Password configuration in persistent storage
        ".config/1Password"
      ];
    };
  };
}
