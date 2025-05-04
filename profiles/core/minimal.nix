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
    (configLib.moduleImport "core/shell/direnv.nix")
    (configLib.moduleImport "core/git.nix")
    (configLib.moduleImport "core/impermanence.nix")
    (configLib.moduleImport "core/locale.nix")
    (configLib.moduleImport "core/nix.nix")
    (configLib.moduleImport "core/packages.nix")
    (configLib.moduleImport "core/secrets.nix")
    (configLib.moduleImport "core/security.nix")
    (configLib.moduleImport "core/shell/starship.nix")
    (configLib.moduleImport "core/shell/zsh.nix")

    # Network modules (flattened structure)
    (configLib.moduleImport "network/default.nix")
  ];

  # Enable non-free firmware
  hardware.enableRedistributableFirmware = true;
}
