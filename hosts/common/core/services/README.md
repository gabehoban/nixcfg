# Services Configuration

This directory contains system services configurations for the NixOS system.

## Files

- **services.nix** - System services
  - fstrim service (SSD optimization)
  - upower service (power management)
  - smartd service (storage device monitoring)
  - Related packages for these services

## Usage

Include the services module in your configuration:

```nix
# Include all service modules
imports = [ ./services ];

# Or specifically import
imports = [ ./services/services.nix ];
```

## Adding New Services

When adding new system services:

1. For related services, group them in a logical file
2. For complex services, create dedicated configuration files
3. Import any new files in default.nix

Example structure for adding database services:

```
services/
├── default.nix
├── services.nix  # Basic system services
├── databases.nix # Database services (PostgreSQL, Redis, etc.)
└── README.md
```

With `default.nix` updated:

```nix
{ ... }: {
  imports = [
    ./services.nix
    ./databases.nix
  ];
}
```
