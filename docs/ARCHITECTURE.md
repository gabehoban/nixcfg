# Architecture Documentation

This document outlines the architecture of this NixOS configuration repository, explaining the relationships between components and the overall design philosophy.

## Component Relationships

```
┌─────────────────┐     ┌───────────────┐     ┌─────────────────┐
│  flake.nix      │────▶│  parts/*.nix  │────▶│  hosts          │
└─────────────────┘     └───────────────┘     └─────────────────┘
        │                       │                      │
        │                       │                      │
        ▼                       ▼                      ▼
┌─────────────────┐     ┌───────────────┐     ┌─────────────────┐
│  lib            │     │  profiles     │◀────│  modules        │
└─────────────────┘     └───────────────┘     └─────────────────┘
                                │                      ▲
                                │                      │
                                ▼                      │
                        ┌───────────────┐             │
                        │  pkgs         │─────────────┘
                        └───────────────┘
```

## Key Components

### 1. Flake Structure

The repository uses `flake-parts` to modularize the flake, breaking it into logical components:

- **devshells.nix**: Development environment configurations
- **packages.nix**: Custom package definitions exposed through the flake
- **nixos-configs.nix**: Machine configurations (mapped to hosts/)
- **overlays.nix**: Package customizations
- **images.nix**: Custom system images (especially for Raspberry Pi)
- **agenix.nix**: Secret management configuration
- **deploy.nix**: Remote deployment settings

### 2. Host Configuration Model

Each host (machine) has its own configuration directory with a consistent structure:

- **default.nix**: Main configuration entry point that imports modules
- **hardware/**: Hardware-specific settings (boot, disks, filesystems)
- **domain-specific files**: Optional configuration for specific services (e.g., config-minio.nix)

Host configurations compose modules and profiles to build the complete system.

### 3. Module System

Modules are organized by functional domain and use a **direct import** design:

- **No Options**: Modules directly configure the system when imported
- **Explicit Control**: Configuration is managed by which modules are imported
- **Module Variants**: Different configurations are separate modules (e.g., `nginx.nix` vs `nginx-ssl.nix`)
- **Clear Dependencies**: Modules document but don't auto-import their dependencies

Module categories:
- **core/**: Essential system functionality (boot, shell, locale, etc.)
- **applications/**: User-facing software packages and configurations
- **desktop/**: Desktop environment settings and components
- **hardware/**: Hardware-specific optimizations and drivers
- **network/**: Networking configuration and services
- **services/**: System and network services
- **users/**: User account configurations

This direct import approach ensures predictable behavior and explicit configuration control.

### 4. Profile System

Profiles pre-compose collections of modules for common use cases:

- **core/minimal.nix**: Essential system services and settings
- **desktop/gnome.nix**: Complete GNOME desktop setup
- **server/homelab.nix**: Configuration for home lab servers
- **server/build-host.nix**: Configuration for build server hosts

Profiles simplify configuration by bundling related modules together.

### 5. Library Functions

The `lib/` directory provides helper functions to simplify working with the configuration:

- **system.nix**: System-related functions (forAllSystems)
- **hosts.nix**: Host-related functions (relativeToRoot)
- **pkgs.nix**: Package management functions (importPackagesByCategory)
- **modules.nix**: Module management functions (moduleImport, profileImport, etc.)

These functions reduce duplication and standardize common operations.

### 6. Secrets Management

The repository uses `agenix` with `agenix-rekey` for a two-layer secret management system:

1. **Master Encryption**: Secrets are encrypted with YubiKey public keys, providing hardware-based security
2. **Host-specific Rekeying**: agenix-rekey automatically re-encrypts secrets for each host's SSH key
3. **Runtime Decryption**: Hosts decrypt their specific secrets during boot using their SSH keys

This approach ensures:
- YubiKey hardware security for master secrets
- No need for YubiKey during deployments
- Host isolation (each host can only decrypt its own secrets)
- All secrets can be safely stored in version control

Directory structure:
- `/secrets/*.age`: Master secrets encrypted with YubiKey
- `/secrets/rekeyed/<hostname>/`: Host-specific rekeyed secrets
- Each host has its own set of re-encrypted secrets

### 7. Package Management

Custom packages are defined in the `pkgs/` directory and made available through overlays:

- **all/**: Packages available on all platforms
- **overlays/**: Package customizations and overrides

## Data Flow

1. When building a system, the flake selects the appropriate host configuration
2. The host configuration imports modules and profiles
3. Modules configure the system based on their specific domain
4. Profiles provide pre-composed collections of modules
5. Library functions provide utility helpers throughout the system

## Deployment Flow

1. Configuration is built locally or on a build host
2. The built system is deployed to target machines using deploy-rs
3. For resource-constrained devices (like RPis), building is done on more powerful machines

## Design Principles

1. **Modularity**: Each component has a single responsibility
2. **Composability**: Components can be mixed and matched
3. **Discoverability**: Clear organization makes finding things easy
4. **Maintainability**: Small, focused components are easier to manage
5. **Reproducibility**: Deterministic builds for consistent results
