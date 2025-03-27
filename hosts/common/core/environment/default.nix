# User environment configuration module
# Groups all user environment-related settings
{ ... }:
{
  imports = [
    ./packages.nix # System-wide packages
    ./dev.nix # Development tools
    ./git.nix # Git configuration
    ./zsh.nix # Z shell configuration
    ./starship.nix # Starship prompt configuration
  ];
}
