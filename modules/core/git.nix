# modules/core/git.nix
#
# Git version control system configuration
{
  lib,
  ...
}:
{
  #
  # User-specific Git configuration via home-manager
  #
  home-manager.users.gabehoban = {
    # Enable XDG base directory specification
    xdg.enable = true;

    # Git configuration
    programs.git = {
      enable = true;

      #
      # User identity
      #
      userName = "Gabe Hoban";
      userEmail = "gabehoban@icloud.com";

      # GPG signing configuration
      signing = {
        key = "AFD8F294983C4F95";
        signByDefault = true;
      };

      # Git LFS (Large File Storage)
      lfs.enable = lib.mkDefault false;

      #
      # Core Git behavior settings
      #
      extraConfig = {
        # Default branch name for new repositories
        init.defaultBranch = "main";

        # Sort branches by commit date (newest first)
        branch.sort = "-committerdate";

        # UI settings
        color.ui = true;
        column.ui = "auto";
        commit.verbose = true;

        # Core settings
        core = {
          editor = "nvim";
          untrackedCache = true;
          whitespace = "trailing-space,space-before-tab,indent-with-non-tab";
        };

        # Signing settings
        commit.gpgsign = true;

        # Checkout settings
        checkout = {
          defaultRemote = "origin";
        };

        # Diff visualization
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };

        # Fetch behavior
        fetch = {
          prune = true;
          pruneTags = true;
        };

        # Merge conflict resolution
        merge = {
          conflictstyle = "zdiff3";
          tool = "nvim -d";
        };

        # Pull/push behavior
        pull.rebase = true;
        push = {
          autoSetupRemote = true;
          followTags = true;
          default = "simple";
        };

        # Rebase settings
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };

        # Tag and repository settings
        tag.sort = "-version:refname";
        safe.bareRepository = "explicit";
      };

      #
      # Git aliases
      #
      aliases = {
        # Pretty log graph
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";

        # Clean up merged branches
        cleanup = "!git branch --merged | grep -v '\\*\\|master\\|develop' | xargs -n 1 -r git branch -d";
      };
    };
  };
}
