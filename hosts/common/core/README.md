# Core NixOS Configuration

This directory contains the core NixOS configuration modules that are common across hosts.

## Structure

- **system/** - System-level configurations (boot, impermanence, locale, nix)
- **network/** - Network-related configurations
- **environment/** - User environment configurations (packages, shell, dev tools)
- **services/** - System services configurations

## Usage

These modules are imported in the main `default.nix` file and can be selectively included in host-specific configurations.

```nix
{ ... }:
{
  imports = [
    ./system
    ./network
    ./environment
    ./services
  ];

  # Host-specific overrides can be added here
}
```
