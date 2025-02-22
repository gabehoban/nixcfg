{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./gabehoban
    ./options.nix
  ];

  config = lib.mkIf config.myUsers.gabehoban.enable {
    programs.zsh.enable = true;

    users = {
      defaultUserShell = pkgs.zsh;
      mutableUsers = false;

      users.root.openssh.authorizedKeys = {
        keyFiles =
          lib.map (file: ../../../secrets/publicKeys + "/${file}")
          (lib.filter (file: lib.hasPrefix "gabehoban_" file)
            (builtins.attrNames (builtins.readDir ../../../secrets/publicKeys)));

        keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIRRxQWNCBRXazO9PRQeK24woXB7jrsYUVJgHdvovVbW"
        ];
      };
    };
  };
}
