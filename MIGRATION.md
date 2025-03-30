# Migration Guide

This document provides instructions for migrating from the previous file structure to the new modular structure.

## Overview of Changes

The main improvements in the new structure are:

1. **More Modular Organization**: Modules are now more atomic and focused on specific functionalities
2. **Profile-Based Approach**: Common module combinations are now grouped into profiles
3. **Improved Library Functions**: New helper functions make module inclusion more flexible
4. **Cleaner Host Configurations**: Host configurations are now more declarative and easier to understand
5. **Better Separation of Concerns**: Clear separation between hardware, system, and user configurations

## Directory Structure Changes

### Previous Structure

```
nixcfg/
├── hosts/
│   ├── common/
│   │   ├── core/           # Core modules (always included)
│   │   ├── optional/       # Optional modules (manually included)
│   │   └── users/          # User configurations
│   └── workstation/        # Host-specific configuration
├── lib/                    # Library functions
├── overlays/               # Nixpkgs overlays
└── pkgs/                   # Custom packages
```

### New Structure

```
nixcfg/
├── hosts/                  # Host-specific configurations
│   └── workstation/        # Workstation configuration
├── modules/                # Atomic, focused modules
│   ├── core/               # Core system modules
│   ├── hardware/           # Hardware-specific modules
│   ├── desktop/            # Desktop environment modules
│   ├── services/           # System service modules
│   ├── applications/       # Application configurations
│   └── users/              # User configurations
├── profiles/               # Reusable configuration patterns
│   ├── core/               # Core system profiles
│   ├── desktop/            # Desktop environment profiles
│   └── hardware/           # Hardware-specific profiles
├── lib/                    # Library functions
├── overlays/               # Nixpkgs overlays
└── pkgs/                   # Custom packages
```

## Migration Steps

### 1. Create the New Directory Structure

First, create the new directories:

```bash
mkdir -p modules/{core,hardware,desktop,services,applications,users}
mkdir -p profiles/{core,desktop,hardware,development}
```

### 2. Move Core Modules

Move core modules from `hosts/common/core/` to `modules/core/`:

```bash
cp -r hosts/common/core/* modules/core/
```

Edit each module to make it more focused and atomic.

### 3. Move Optional Modules

Move optional modules from `hosts/common/optional/` to their respective categories in `modules/`:

```bash
cp -r hosts/common/optional/hardware/* modules/hardware/
cp -r hosts/common/optional/desktop/* modules/desktop/
cp -r hosts/common/optional/services/* modules/services/
cp -r hosts/common/optional/applications/* modules/applications/
```

Edit each module to make it more atomic and focused.

### 4. Move User Configurations

Move user configurations from `hosts/common/users/` to `modules/users/`:

```bash
cp -r hosts/common/users/* modules/users/
```

### 5. Create Profiles

Create profiles that combine related modules to provide common functionality patterns. For example:

- `profiles/core/minimal.nix`: A minimal but functional system
- `profiles/desktop/gnome.nix`: A complete GNOME desktop environment
- `profiles/hardware/amd-desktop.nix`: Configuration for AMD desktop systems

### 6. Update Library Functions

Update the library functions in `lib/` to support the new structure:

1. Add `modules.nix` with helper functions for working with modules and profiles
2. Update `default.nix` to export these new functions

### 7. Update Host Configurations

Update each host configuration to use the new module and profile structure:

1. Import profiles instead of manually importing individual modules
2. Use the new library functions to import modules and profiles
3. Keep host-specific customizations in the host configuration

Example:

```nix
{
  configLib,
  inputs,
  ...
}:
{
  networking.hostName = "workstation";

  imports = [
    # Use profiles
    (configLib.profileImport "hardware/amd-desktop.nix")
    (configLib.profileImport "desktop/gnome.nix")

    # Host-specific hardware configuration
    ./hardware

    # Additional modules
    (configLib.moduleImport "services/ssh.nix")
    (configLib.moduleImport "users/gabehoban.nix")
  ];
}
```

### 8. Test the New Configuration

Test the new configuration to ensure everything works correctly:

```bash
nixos-rebuild dry-build --flake .#workstation
```

Once everything is working correctly, you can switch to the new configuration:

```bash
nixos-rebuild switch --flake .#workstation
```

## Benefits of the New Structure

- **Modularity**: Each module has a specific, focused purpose
- **Reusability**: Profiles combine common module patterns for easy reuse
- **Discoverability**: Clear directory structure makes it easy to find modules
- **Maintainability**: Smaller, focused modules are easier to maintain
- **Flexibility**: More granular control over which modules are included
