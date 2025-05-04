# overlays/packages.nix
#
# Custom package overlay
# Makes custom packages from the pkgs directory available in the global namespace
_: final: _prev:
let
  # Import all custom packages from pkgs directory
  customPackages = import ../pkgs { pkgs = final; };
in
{
  # ==================== CUSTOM PACKAGES ====================

  # Make custom packages directly available in pkgs namespace
  inherit (customPackages) zsh-histdb-skim nixfmt-plus;

  # Keep the customPackages attribute for reference
  inherit customPackages;
}
