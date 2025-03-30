# NixOS Configuration

This repository contains a modular NixOS configuration using the Nix Flakes system. It's designed to be maintainable, flexible, and scalable for different hosts and use cases.

## Structure

The configuration is organized into the following directories:

- **hosts/**: Host-specific configurations
  - Each subdirectory represents a different machine (e.g., `workstation`, `server`, etc.)
  - Host configurations import modules and profiles as needed
  
- **modules/**: Atomic, focused modules for specific functionality
  - `core/`: Essential system modules (boot, nix, locale, etc.)
  - `hardware/`: Hardware-specific modules (CPUs, GPUs, etc.)
  - `desktop/`: Desktop environment modules (GNOME, KDE, etc.)
  - `services/`: System service modules (SSH, audio, etc.)
  - `applications/`: Application configurations
  - `users/`: User profile configurations
  
- **profiles/**: Reusable configuration patterns that combine modules
  - `core/`: Core system profiles (minimal, desktop, server)
  - `desktop/`: Desktop environment profiles
  - `hardware/`: Hardware-specific profiles
  - `development/`: Development environment profiles
  
- **lib/**: Helper functions and utilities
- **overlays/**: Custom package overlays
- **pkgs/**: Custom package definitions

## Usage

### Building and Activating

To build and activate a configuration:

```bash
# Build and activate a specific host configuration
nixos-rebuild switch --flake .#workstation
```

### Adding New Hosts

1. Create a new directory in `hosts/` with your hostname
2. Create a `default.nix` file in that directory that imports the necessary profiles and modules
3. Update `flake.nix` to include your new host in the `nixosConfigurations` attribute

### Adding New Modules

1. Create a new file in the appropriate subdirectory of `modules/`
2. Write your module configuration
3. Import it in your host configuration or in a profile

### Creating Profiles

1. Create a new file in the appropriate subdirectory of `profiles/`
2. Import the necessary modules using the `configLib.moduleImport` function
3. Import the profile in your host configuration using the `configLib.profileImport` function

## Design Philosophy

This configuration follows these design principles:

1. **Modularity**: Each module has a specific, focused purpose
2. **Reusability**: Profiles combine common module patterns for easy reuse
3. **Discoverability**: Clear directory structure makes it easy to find modules
4. **Maintainability**: Smaller, focused modules are easier to maintain
5. **Flexibility**: More granular control over which modules are included

## Migration

If you're migrating from a previous NixOS configuration structure, see the [MIGRATION.md](./MIGRATION.md) guide for step-by-step instructions.

## License

This project is licensed under the terms of the MIT license.