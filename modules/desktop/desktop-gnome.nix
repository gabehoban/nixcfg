# modules/desktop/desktop-gnome.nix
#
# GNOME desktop environment configuration
{ pkgs, ... }:

{
  #
  # Core GNOME configuration
  #
  services = {
    # X11 windowing system setup
    xserver = {
      enable = true;
      xkb.layout = "us";
      excludePackages = with pkgs; [ xterm ];

      # Enable GDM and GNOME desktop
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    # Enable GNOME keyring for secure credential storage
    gnome.gnome-keyring.enable = true;
  };

  #
  # GNOME Shell configuration and extensions
  #
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        lockAll = true;
        settings = {
          # Shell extensions configuration
          "org/gnome/shell" = {
            disabled-extensions = "";
            enabled-extensions = [
              "blur-my-shell@aunetx"
              "dash-to-dock@micxgx.gmail.com"
            ];
            # Configure default applications that appear in the GNOME dock/favorites
            # These will be displayed in the order listed below
            favorite-apps = [
              "org.gnome.Nautilus.desktop"
              "firefox.desktop"
              "steam.desktop"
              "org.gnome.Console.desktop"
              "org.gnome.Calendar.desktop"
              "dev.zed.Zed.desktop"
            ];
          };

          # Dash to Dock settings
          "org/gnome/shell/extensions/dash-to-dock" = {
            click-action = "minimize-or-previews";
            show-trash = false;
            multi-monitor = true;
            running-indicator-style = "DOTS";
            custom-theme-shrink = false;
          };
        };
      }
    ];
  };

  #
  # Wayland support configuration
  #
  environment.sessionVariables = {
    "NIXOS_OZONE_WL" = "1";
    "MOZ_ENABLE_WAYLAND" = "1";
    "GDK_BACKEND" = "wayland,x11";
    "CLUTTER_BACKEND" = "wayland";
  };

  #
  # Additional GNOME packages and extensions
  #
  environment.systemPackages = with pkgs; [
    # GNOME tools
    gnome-tweaks
    adwaita-icon-theme

    # GNOME Shell extensions
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
  ];

  #
  # Exclude unnecessary GNOME packages
  #
  environment.gnome.excludePackages = with pkgs; [
    atomix
    cheese
    epiphany
    evince
    geary
    gedit
    gnome-characters
    gnome-contacts
    gnome-initial-setup
    gnome-music
    gnome-photos
    gnome-terminal
    gnome-tour
    hitori
    iagno
    tali
    totem
  ];

  #
  # Persistence configuration
  #
  environment.persistence."/persist" = {
    users.gabehoban.directories = [
      ".config/autostart"
      {
        directory = ".local/share/keyrings";
        mode = "0700";
      }
      ".local/share/gvfs-metadata"
    ];
  };
}