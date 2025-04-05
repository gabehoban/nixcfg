# NixOS Installation Images

This directory contains configurations for building NixOS installation images for different hosts.

## Structure

- `default.nix`: Common image configuration and helper functions
- `workstation.nix`: Workstation-specific installation image
- `sekio.nix`: Raspberry Pi SD card image for Sekio

## Building Images

To build an installation image, run:

```bash
# For the workstation image
nix build .#nixosConfigurations.iso-workstation.config.system.build.isoImage
```

## Creating a New Host Image

To create an installation image for a new host:

1. Create a new file named `<hostname>.nix`
2. Use the common `mkInstallationImage` function from `default.nix`
3. Add host-specific customizations in the `extraModules` parameter

Example:

```nix
# hostname.nix
{
  description = "Hostname NixOS installation";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { nixpkgs, ... }:
    let
      common = import ./default.nix;
    in
    {
      nixosConfigurations = {
        iso-hostname = common.mkInstallationImage {
          hostName = "hostname";
          extraModules = [
            # Host-specific modules
          ];
        } { inherit nixpkgs; };
      };
    };
}
```
