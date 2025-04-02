# modules/desktop/desktop-fonts.nix
#
# System-wide font configuration
{
  pkgs,
  ...
}:
{
  #
  # License configuration
  #
  # Accept JoyPixels license for emoji support
  nixpkgs.config.joypixels.acceptLicense = true;

  #
  # Font packages and configuration
  #
  fonts = {
    packages = with pkgs; [
      # Icon fonts
      material-icons # Material design icons
      material-design-icons

      # Sans-serif fonts
      roboto # Google's modern sans-serif
      work-sans # Clean, minimal sans-serif
      inter # Modern typeface
      lato # Balanced sans-serif
      lexend # Readable sans-serif
      jost # Geometric sans-serif
      source-sans # Adobe Source Sans
      source-sans-pro # Adobe Source Sans Pro
      ubuntu_font_family # Ubuntu's custom font family

      # Serif and display fonts
      comic-neue # Comic Sans successor
      comfortaa # Rounded geometric sans-serif

      # Monospace fonts
      dejavu_fonts # Unicode coverage font family
      iosevka-bin # Slender monospace
      nerd-fonts.jetbrains-mono # Developer-oriented with icons
      nerd-fonts.caskaydia-cove # Cascadia Code with icons

      # Emoji and symbol fonts
      noto-fonts-emoji # Google's emoji font
      twemoji-color-font # Twitter's emoji font
      joypixels # JoyPixels emoji font

      # CJK (Chinese, Japanese, Korean) fonts
      noto-fonts # Google's Noto fonts
      noto-fonts-cjk-sans # CJK support

      # Math and technical fonts
      lmodern # Latin Modern
      lmmath # Latin Modern Math
    ];
  };
}
