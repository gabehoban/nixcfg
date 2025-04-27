{ lib, pkgs, ... }:
{
  home-manager.users.gabehoban = {
    programs.yt-dlp = {
      enable = true;
      package = pkgs.yt-dlp_git;

      settings = {
        audio-format = "best";
        embed-thumbnail = true;
        embed-metadata = true;

        format = "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best";
        prefer-free-formats = true;

        sponsorblock-mark = "all";
        sponsorblock-remove = "all";

        downloader = lib.getExe pkgs.aria2;
      };
    };
    home.packages = [ pkgs.aria2 ];
  };
}
