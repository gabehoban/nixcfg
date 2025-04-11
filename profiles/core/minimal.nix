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
    (configLib.moduleImport "core/direnv.nix")
    (configLib.moduleImport "core/git.nix")
    (configLib.moduleImport "core/impermanence.nix")
    (configLib.moduleImport "core/locale.nix")
    (configLib.moduleImport "core/nix.nix")
    (configLib.moduleImport "core/packages.nix")
    (configLib.moduleImport "core/secrets.nix")
    (configLib.moduleImport "core/security.nix")
    (configLib.moduleImport "core/starship.nix")
    (configLib.moduleImport "core/zsh.nix")

    # Network modules (flattened structure)
    (configLib.moduleImport "network/default.nix")

    # Service modules (flattened structure)
    (configLib.moduleImport "services/tailscale.nix")
  ];

  # Enable non-free firmware
  hardware.enableRedistributableFirmware = true;
}
