# Services configuration module
# Groups all service-related settings
{ ... }:
{
  imports = [
    ./services.nix # Core services configuration
  ];
}
