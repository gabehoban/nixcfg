{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;

        keybindings = [
          {
            "key" = "alt+e";
            "command" = "workbench.action.quickOpen";
          }
          {
            "key" = "ctrl+p";
            "command" = "-workbench.action.quickOpen";
          }
          {
            "key" = "ctrl+p";
            "command" = "workbench.action.showCommands";
          }
          {
            "key" = "ctrl+shift+t";
            "command" = "-workbench.action.reopenClosedEditor";
          }
          {
            "key" = "ctrl+shift+t";
            "command" = "workbench.action.tasks.runTask";
          }
          {
            "key" = "ctrl+shift+p";
            "command" = "-workbench.action.showCommands";
          }
        ];

        userSettings = {
          "diffEditor.ignoreTrimWhitespace" = false;
          "direnv.restart.automatic" = true;
          "editor.fontSize" = lib.mkForce 14;
          "editor.formatOnPaste" = true;
          "editor.formatOnSave" = true;
          "editor.formatOnType" = true;
          "editor.rulers" = [80];
          "explorer.confirmDelete" = false;
          "files.autoSave" = "afterDelay";
          "git.autoStash" = true;
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "github.gitProtocol" = "ssh";
          "window.menuBarVisibility" = "hidden";
          "window.zoomLevel" = 1.7;

          "window.titleBarStyle" =
            if config.myHome.desktop.gnome.enable
            then "custom"
            else "native";
        };

        extensions = with pkgs.vscode-extensions; [
          esbenp.prettier-vscode
          foxundermoon.shell-format
          github.vscode-github-actions
          github.vscode-pull-request-github
          jnoortheen.nix-ide
          mads-hartmann.bash-ide-vscode
          mkhl.direnv
          ms-python.python
          oderwat.indent-rainbow
          rubymaniac.vscode-paste-and-indent
        ];
      };
    };
  };
}
