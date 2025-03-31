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
        # GPG sign all commits
        commit.gpgsign = true;

        # Use "main" as the default branch name for new repositories
        init.defaultBranch = "main";

        # Rebase local changes on pull instead of creating merge commits
        pull.rebase = true;

        # Automatically set up remote tracking when pushing a new branch
        push.autoSetupRemote = true;
      };

      # Useful Git aliases
      aliases = {
        # Remove branches that have been merged to master/develop
        cleanup = "!git branch --merged | grep -v '\\*\\|master\\|develop' | xargs -n 1 -r git branch -d";

        # Pretty graph log with colors and author info
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      };
    };
  };
}
