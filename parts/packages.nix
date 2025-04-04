# parts/packages.nix
#
# Custom packages and formatter configuration
{ inputs, ... }:
{
  perSystem = { config, self', inputs', pkgs, system, ... }: {
    # Custom packages
    packages = import ../pkgs { inherit pkgs; };
    
    # Code formatter
    formatter = (import ../pkgs { inherit pkgs; }).nixfmt-plus;
  };
}