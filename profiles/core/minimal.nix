# profiles/core/minimal.nix
#
# A minimal but functional NixOS system profile.
# This profile includes only the essential core modules needed for a basic system.
{
  configLib,
  ...
}:
{
  imports = [
    # Core system modules
    (configLib.moduleImport "core/boot.nix")
    (configLib.moduleImport "core/git.nix")
    # Impermanence is now opt-in via impermanence.enable = true
    (configLib.moduleImport "core/impermanence.nix")
    (configLib.moduleImport "core/locale.nix")
    (configLib.moduleImport "core/nix.nix")
    (configLib.moduleImport "core/packages.nix")
    (configLib.moduleImport "core/secrets.nix")
    (configLib.moduleImport "core/starship.nix")
    (configLib.moduleImport "core/zsh.nix")
    (configLib.moduleImport "core/direnv.nix")

    # Network modules (flattened structure)
    (configLib.moduleImport "network/basic.nix")
  ];

  # Enable non-free firmware
  hardware.enableRedistributableFirmware = true;
}
