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
    (configLib.moduleImport "core/impermanence.nix")
    (configLib.moduleImport "core/locale.nix")
    (configLib.moduleImport "core/nix.nix")
    (configLib.moduleImport "core/packages.nix")
    (configLib.moduleImport "core/secrets.nix")
    (configLib.moduleImport "core/starship.nix")
    (configLib.moduleImport "core/zsh.nix")

    # Network modules (flattened structure)
    (configLib.moduleImport "network/basic.nix")
  ];

  # Enable all firmware including non-free
  hardware.enableAllFirmware = true;

  # NixOS release version (do not change unless you know what you're doing)
  system.stateVersion = "24.11";
}
