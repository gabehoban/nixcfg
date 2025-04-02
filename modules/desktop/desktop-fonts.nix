# modules/desktop/desktop-fonts.nix
#
# System-wide font configuration
{ pkgs, ... }:
{
  # Accept JoyPixels license for emoji support
  nixpkgs.config.joypixels.acceptLicense = true;

  fonts = {
    packages = with pkgs; [
      # Icon fonts
      material-icons
      material-design-icons

      # Sans-serif fonts
      roboto
      work-sans
      inter
      lato
      lexend
      jost
      source-sans
      source-sans-pro
      ubuntu_font_family

      # Serif and display fonts
      comic-neue
      comfortaa

      # Monospace fonts
      dejavu_fonts
      iosevka-bin
      nerd-fonts.jetbrains-mono
      nerd-fonts.caskaydia-cove

      # Emoji and symbol fonts
      noto-fonts-emoji
      twemoji-color-font
      joypixels

      # CJK (Chinese, Japanese, Korean) fonts
      noto-fonts
      noto-fonts-cjk-sans

      # Math and technical fonts
      lmodern
      lmmath
    ];
  };
}
