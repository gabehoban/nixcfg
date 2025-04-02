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

  # Individual package overrides
  # examplePackage = prev.examplePackage.override { ... };

  # Package fixes and patches
  # somePackage = prev.somePackage.overrideAttrs (old: { ... });
}
