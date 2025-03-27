# Gaming support configuration (Steam, Proton, etc.)
{ pkgs, ... }:
{
  #
  # Steam configuration
  #
  programs = {
    steam = {
      enable = true;

      # Enable Gamescope Wayland session for better gaming performance
      gamescopeSession.enable = true;

      # Extra runtime libraries for Steam and games
      extraPackages = with pkgs; [
        # X11 libraries
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver

        # Multimedia libraries
        libpng
        libpulseaudio
        libvorbis

        # System libraries
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
    };
  };

  #
  # Additional gaming utilities
  #
  environment.systemPackages = with pkgs; [
    protonup # Proton GE version manager
    protontricks # Winetricks wrapper for Proton prefixes
  ];

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
