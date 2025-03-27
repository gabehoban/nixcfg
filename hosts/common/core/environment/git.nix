{
  lib,
  ...
}:
{
  home-manager.users.gabehoban = {
    xdg.enable = true;

    programs.git = {
      enable = true;
      userName = "Gabe Hoban";
      userEmail = "gabehoban@icloud.com";
      signing = {
        key = "AFD8F294983C4F95";
        signByDefault = true;
      };
      lfs.enable = lib.mkDefault false;
      extraConfig = {
        commit.gpgsign = true;
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
      aliases = {
        cleanup = "!git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 -r git branch -d";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      };
    };
  };
}
