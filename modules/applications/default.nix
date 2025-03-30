# modules/applications/default.nix
#
# Combined applications module
# Imports all application modules
{
  imports = [
    # Browser applications
    ./app-firefox.nix
    
    # Communication applications
    ./app-discord.nix
    
    # Development applications
    ./app-zed.nix
    
    # Gaming applications
    ./app-gaming.nix
    
    # Productivity applications
    ./app-claude.nix
    
    # System applications
    ./app-1password.nix
  ];
}