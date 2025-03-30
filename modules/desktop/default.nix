# modules/desktop/default.nix
#
# Combined desktop environment modules
# Imports all desktop-related modules
{
  imports = [
    # Font configuration
    ./desktop-fonts.nix
    
    # Desktop environments
    ./desktop-gnome.nix
    
    # Theming and appearance
    ./desktop-stylix.nix
  ];
}