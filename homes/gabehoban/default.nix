{
  config,
  lib,
  pkgs,
  self,
  ...
}: {
  imports = [
    ./firefox
    ./vsCode
    # ./secrets.nix
    self.homeManagerModules.default
    self.inputs.agenix.homeManagerModules.default
  ];

  gtk.gtk3.bookmarks = lib.mkAfter [
    "file://${config.home.homeDirectory}/sync"
  ];

  home = {
    homeDirectory = "/home/gabehoban";

    packages = with pkgs; [
      curl
      fractal
      rclone
      tauon
      vesktop
    ];

    stateVersion = "24.05";
    username = "gabehoban";
  };

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      userName = "Gabe Hoban";
      userEmail = "gabehoban@icloud.com";

      extraConfig = {
        color.ui = true;
        github.user = "gabehoban";
        push.autoSetupRemote = true;
      };
    };

    gitui.enable = true;
    home-manager.enable = true;

    wezterm.enable = true;
  };

  systemd.user.startServices = true; # Needed for auto-mounting agenix secrets.

  myHome = {
    profiles = {
      defaultApps = {
        enable = true;
        editor.package = config.programs.vscode.package;
      };

      shell.enable = true;
    };

    programs.fastfetch.enable = true;
  };
}
