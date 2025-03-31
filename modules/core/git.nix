{
  lib,
  ...
}:
{
  home-manager.users.gabehoban = {
    # Enable XDG base directory specification
    xdg.enable = true;

    # Git configuration
    programs.git = {
      enable = true;

      # User identity
      userName = "Gabe Hoban";
      userEmail = "gabehoban@icloud.com";

      # GPG signing configuration
      signing = {
        key = "AFD8F294983C4F95";
        signByDefault = true;
      };

      # Git LFS (Large File Storage)
      lfs.enable = lib.mkDefault false;

      # Core Git behavior settings
      extraConfig = {
        init.defaultBranch = "main";
        branch.sort = "-committerdate";
        color.ui = true;
        column.ui = "auto";
        commit.verbose = true;
        core = {
          editor = "nvim";
          untrackedCache = true;
          whitespace = "trailing-space,space-before-tab,indent-with-non-tab";
        };
        commit.gpgsign = true;
        checkout = {
          defaultRemote = "origin";
        };
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };
        fetch = {
          prune = true;
          pruneTags = true;
        };
        merge = {
          conflictstyle = "zdiff3";
          tool = "nvim -d";
        };
        pull.rebase = true;
        push = {
          autoSetupRemote = true;
          followTags = true;
          default = "simple";
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };
        tag.sort = "-version:refname";
        safe.bareRepository = "explicit";
      };

      # Useful Git aliases
      aliases = {
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        cleanup = "!git branch --merged | grep -v '\\*\\|master\\|develop' | xargs -n 1 -r git branch -d";
      };
    };
  };
}
