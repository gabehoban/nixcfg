# System Configuration

This directory contains system-level NixOS configurations.

## Files

- **boot.nix** - Boot and kernel configurations
  - Boot loader settings (lanzaboote/systemd-boot)
  - Kernel parameters and packages
  - Plymouth configuration
  - ZFS package configuration
  - Process scheduling services (scx, ananicy)

- **impermanence.nix** - System state persistence configuration
  - Directory and file persistence settings
  - Home directory persistence
  - System activation scripts for persistent directories

- **locale.nix** - Locale and timezone settings
  - Time zone configuration
  - Default locale

- **nix.nix** - Nix package manager configuration
  - Nix settings and optimization
  - Garbage collection
  - Experimental features
  - Cache substituters and keys

## Usage

Include individual modules or the entire directory:

```nix
# Include all system modules
imports = [ ./system ];

# Or import specific modules
imports = [
  ./system/boot.nix
  ./system/impermanence.nix
];
```
