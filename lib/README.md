# Library Functions

This directory contains helper functions and utilities to make the NixOS configuration more maintainable and reusable.

## Files

- `default.nix`: Exports all library functions
- `hosts.nix`: Functions for working with host configurations
- `modules.nix`: Functions for importing and organizing modules
- `pkgs.nix`: Functions for working with packages and overlays
- `system.nix`: System-level utility functions

## Usage

These library functions are imported in `flake.nix` and made available as `configLib` throughout the configuration. They provide a consistent interface for common operations like importing modules, profiles, and working with system configurations.

Example usage:

```nix
# Import a module
configLib.moduleImport ./modules/core/boot.nix

# Import a profile
configLib.profileImport ./profiles/desktop/gnome.nix
```

## Extending

When adding new library functions:

1. Create a new file or add to an existing one based on the function's purpose
2. Export the function in `default.nix`
3. Document the function with clear comments explaining its purpose and usage
