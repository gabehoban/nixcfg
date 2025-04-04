# modules/applications/app-gaming.nix
#
# Gaming support configuration (Steam, Proton, etc.)
{
  pkgs,
  config,
  lib,
  ...
}:
{
  #
  # Steam configuration
  #
  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    package = pkgs.steam.override { privateTmp = false; };
    # Open ports in the firewall for Steam Remote Play
    remotePlay.openFirewall = true;
    # Open ports in the firewall for Source Dedicated Server
    dedicatedServer.openFirewall = true;
    # Open ports in the firewall for Steam Local Network Game Transfers
    localNetworkGameTransfers.openFirewall = true;
  };

  #
  # Steam package overrides
  #
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs =
        pkgs: with pkgs; [
          # Microcompositor for games
          gamescope
          # .NET GDI+ compatible library
          libgdiplus
          # PNG library
          libpng
          # PulseAudio client library
          libpulseaudio
          # Vorbis audio codec
          libvorbis
          # X cursor management library
          xorg.libXcursor
          # X input extension library
          xorg.libXi
          # X multiple monitors library
          xorg.libXinerama
          # X screen saver extension
          xorg.libXScrnSaver
        ];
    };
  };

  #
  # Gaming utility packages
  #
  environment.systemPackages = with pkgs; [
    # Mod manager for Kerbal Space Program
    ckan
    # Microcompositor for Steam games
    gamescope
  ];

  #
  # Persistence configuration
  #
  impermanence.users.gabehoban.directories = [
    # Desktop shortcut and icon storage
    ".local/share/applications"
    ".local/share/icons/hicolor"

    # Steam configuration and game library
    ".steam"
    ".local/share/CKAN"
    ".local/share/Steam"
  ];
}
