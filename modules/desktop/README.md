# Desktop

This directory contains modules for configuring desktop environments and related components.

## Modules

- `default.nix`: Common desktop settings shared across environments
- `desktop-fonts.nix`: Font configuration for desktop environments
- `desktop-gnome.nix`: GNOME desktop environment configuration
- `desktop-stylix.nix`: System-wide theming via Stylix

## Usage

Import desktop modules in your host configuration or through a desktop profile:

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/desktop/desktop-gnome.nix
    ./modules/desktop/desktop-fonts.nix
  ];
}
```

For most cases, you should use the desktop profiles in `profiles/desktop/` which import the appropriate desktop modules with reasonable configurations.

## Adding New Desktop Environments

When adding support for a new desktop environment:

1. Create a new file following the `desktop-[environment].nix` naming convention
2. Include detailed documentation about the desktop environment
3. Configure default applications, themes, and settings
4. Ensure compatibility with existing desktop modules like fonts and theming
5. Create a corresponding profile in `profiles/desktop/` if appropriate
