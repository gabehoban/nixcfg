# modules/desktop/desktop-stylix.nix
#
# Stylix system-wide theming configuration
{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # Import the Stylix NixOS module
  imports = [ inputs.stylix.nixosModules.stylix ];

  #
  # Qt theming support
  #
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  #
  # Stylix theme configuration
  #
  stylix = {
    enable = true;

    # Wallpaper configuration
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/wallpapers/nix-wallpaper-nineish-catppuccin-frappe.png";
      sha256 = "03lrj64zig62ibhcss5dshy27kvw363gzygm4rgk7ihbdjj2sw7w";
    };

    # Base color scheme (Nord theme)
    polarity = "dark";
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/nord.yaml";

    # Target-specific configurations
    targets.qt.platform = lib.mkForce "qtct";

    # Cursor theme
    cursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 12;
    };

    # Font configuration
    fonts = {
      # Monospace font (for terminal, code, etc.)
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };

      # Emoji font
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };

      # Font sizes for specific applications
      sizes = {
        terminal = 13;
      };
    };
  };
}