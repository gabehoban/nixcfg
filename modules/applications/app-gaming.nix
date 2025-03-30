# modules/applications/app-gaming.nix
#
# Gaming support configuration (Steam, Proton, etc.)
{ pkgs, ... }:
{
  #
  # Steam configuration
  #
  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    package = pkgs.steam.override { privateTmp = false; };
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs =
        pkgs: with pkgs; [
          libgdiplus
          libpng
          libpulseaudio
          libvorbis
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
        ];
    };
  };

  #
  # Persistent configuration
  #
  environment.persistence."/persist" = {
    users.gabehoban.directories = [
      # Desktop shortcut and icon storage
      ".local/share/applications"
      ".local/share/icons/hicolor"

      # Steam configuration and game library
      ".steam"
      ".local/share/Steam"
    ];
  };
}