# parts/packages.nix
#
# Custom packages and formatter configuration
_:
{
  perSystem = { pkgs, ... }: {
    # Custom packages
    packages = import ../pkgs { inherit pkgs; };
    
    # Code formatter
    formatter = (import ../pkgs { inherit pkgs; }).nixfmt-plus;
  };
}