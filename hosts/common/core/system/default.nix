# System configuration module
# Groups all system-level settings files
{ ... }:
{
  imports = [
    ./boot.nix # Boot, kernel, and early system initialization
    ./impermanence.nix # State persistence management
    ./locale.nix # Language and timezone settings
    ./nix.nix # Nix package manager configuration
  ];
}
