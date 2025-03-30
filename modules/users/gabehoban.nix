# modules/users/gabehoban.nix
#
# User configuration for gabehoban
_: {
  users = {
    users = {
      gabehoban = {
        isNormalUser = true;
        description = "Gabe Hoban";
        extraGroups = [
          "networkmanager"
          "wheel"
          "media"
          "input"
          "libvirt"
          "audio"
          "video"
          "power"
          "users"
          "kvm"
        ];
        hashedPassword = "$7$CU..../....6H2Cxu.oYQY6HBpWe1OSG/$RnZAJioALqERJR6zUbApQWFbVWpmJNi4S/eo5KYM.G5";
        openssh = {
          authorizedKeys.keys = [
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPH/GNUI0con3U+Jmh7tYAnvGTT9bSzkA5kUJAWy0UT8AAAABHNzaDo="
          ];
        };
      };
      root = {
        isNormalUser = false;
        hashedPassword = "$7$CU..../....t306LucALVXUzf9M43FqQ1$Pn2YxX4.TiCK9vaRRst7b6R2xxTeAARC1hxCZ1SBlu1";
      };
    };
    groups = {
      docker = { };
      libvirt = { };
    };
  };
  home-manager.users.gabehoban = {
    home.username = "gabehoban";
    home.homeDirectory = "/home/gabehoban";
    home.stateVersion = "24.11";
  };
  security.sudo.wheelNeedsPassword = false;
}