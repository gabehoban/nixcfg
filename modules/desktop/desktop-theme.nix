# modules/desktop/desktop-theme.nix
#
# Stylix system-wide theming configuration
{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  #
  # Stylix module import
  #
  # Import the Stylix NixOS module
  imports = [ inputs.stylix.nixosModules.stylix ];

  #
  # Qt theming support
  #
  qt = {
    enable = true;
    platformTheme = lib.mkDefault "qt5ct";
  };

  #
  # Stylix theme configuration
  #
  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/wallpapers/nix-wallpaper-nineish-catppuccin-frappe.png";
      sha256 = "03lrj64zig62ibhcss5dshy27kvw363gzygm4rgk7ihbdjj2sw7w";
    };
    targets.qt.enable = false;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    cursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 12;
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        terminal = 13;
      };
    };
    homeManagerIntegration.autoImport = true;
  };

  #
  # User-specific Stylix configuration
  #
  home-manager.users.gabehoban.stylix = {
    enable = true;
    autoEnable = true;

    targets.zed.enable = false;

    iconTheme = {
      enable = true;
      package = pkgs.vimix-icon-theme;
      dark = "Vimix-black-dark";
      light = "Vimix-black-dark";
    };
  };

  #
  # System services configuration
  #
  systemd.services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
}
