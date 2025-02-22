{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.myUsers.gabehoban.enable {
    users.users.gabehoban = {
      description = "Gabe Hoban";
      extraGroups = config.myUsers.defaultGroups;
      hashedPassword = config.myUsers.gabehoban.password;
      isNormalUser = true;

      openssh.authorizedKeys = {
        keyFiles =
          lib.map (file: ../../../../secrets/publicKeys + "/${file}")
          (lib.filter (file: lib.hasPrefix "gabehoban_" file)
            (builtins.attrNames (builtins.readDir ../../../../secrets/publicKeys)));

        keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIRRxQWNCBRXazO9PRQeK24woXB7jrsYUVJgHdvovVbW" # termux on winona
        ];
      };

      shell = pkgs.zsh;
      uid = 1000;
    };
  };
}
