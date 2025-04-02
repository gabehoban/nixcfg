# Core

This directory contains essential core system modules that provide fundamental functionality for all NixOS configurations.

## Modules

- `boot.nix`: System boot loader configuration and options
- `git.nix`: System-wide Git configuration
- `impermanence.nix`: Configuration for ephemeral root filesystem with persistent data
- `locale.nix`: System locale, timezone, and language settings
- `network/basic.nix`: Basic network configuration
- `nix.nix`: Nix package manager configuration and options
- `packages.nix`: Core system packages
- `starship.nix`: Starship shell prompt configuration
- `zsh.nix`: ZSH shell configuration

## Usage

These core modules are typically imported in the `minimal.nix` profile, which should be included in all host configurations:

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ../profiles/core/minimal.nix
    # Additional modules
  ];
}
```

If needed, individual core modules can be imported directly, but this is not recommended for most use cases.

## Adding New Core Modules

When adding a new core module:

1. Ensure the module is truly essential for basic system functionality
2. Include detailed documentation at the top of the file
3. Configure reasonable defaults that work across different hosts
4. Add appropriate options for customization when needed
