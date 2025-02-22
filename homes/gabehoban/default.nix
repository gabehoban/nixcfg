{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  onePassPath = "~/.1password/agent.sock";
in {
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
      aria2
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
    yt-dlp = {
      enable = true;
      package = self.inputs.chaotic.packages.${pkgs.system}.yt-dlp_git;
      settings = {
        embed-metadata = true;
        sponsorblock-mark = "all";
        embed-thumbnail = true;
        format = "bestvideo+bestaudio/best";
        downloader = lib.getExe pkgs.aria2;
        downloader-args = "aria2c:'-c -x16 -s16 -k2M'";
        restrict-filenames = true;
        merge-output-format = "mkv";
        output = "~/videos/YouTube/%(title)s--%(uploader)s--%(id)s.%(ext)s";
      };
    };

    git = {
      enable = true;
      lfs.enable = true;
      userName = "Gabe Hoban";
      userEmail = "gabehoban@icloud.com";

      extraConfig = {
        color.ui = true;
        github.user = "gabehoban";
        push.autoSetupRemote = true;
        gpg = {
          format = "ssh";
        };
        "gpg \"ssh\"" = {
          program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
        };
        commit = {
          gpgsign = true;
        };
        user = {
          signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIRRxQWNCBRXazO9PRQeK24woXB7jrsYUVJgHdvovVbW";
        };
      };
    };
    ssh = {
      enable = true;
      extraConfig = ''
        Host *
            IdentityAgent ${onePassPath}
      '';
    };
    gitui.enable = true;
    home-manager.enable = true;
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
