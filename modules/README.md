# NixOS Modules

This directory contains modular NixOS configurations organized by functional category.

## 📋 Design Philosophy

This project uses a **direct import** approach:
- ✅ Modules configure the system directly when imported
- ❌ No options-based configuration (`mkOption`, `mkEnableOption`)
- 🎯 Configuration control via selective imports
- 🔀 Different configurations as separate module variants

## 📁 Directory Structure

```
modules/
├── applications/   # User-facing applications
├── core/          # Essential system components
├── desktop/       # Desktop environment modules
├── hardware/      # Hardware-specific configs
├── network/       # Network configuration
├── services/      # System and network services
└── users/         # User account configurations
```

## 🏷️ Naming Conventions

Each module follows strict naming conventions for consistency:

| Category | Prefix | Example | Purpose |
|----------|--------|---------|---------|
| Desktop Apps | `desktop-` | `desktop-firefox.nix` | GUI applications |
| CLI Tools | `cli-` | `cli-youtubedl.nix` | Command-line tools |
| Dev Tools | `dev-` | `dev-zed.nix` | Development environments |
| Games | `game-` | `game-steam.nix` | Gaming applications |
| System Services | `sys-` | `sys-ssh.nix` | Core system services |
| Web Services | `web-` | `web-nginx.nix` | Web servers and proxies |
| Media Services | `media-` | `media-plex.nix` | Media streaming/management |
| Monitoring | `mon-` | `mon-prometheus.nix` | Monitoring and metrics |
| Storage | `storage-` | `storage-minio.nix` | Storage services |
| Security | `sec-` | `sec-yubikey.nix` | Security components |

## 🔧 Usage

### Importing Modules

In your host configuration:

```nix
{
  imports = [
    # Import specific modules needed for this host
    (configLib.moduleImport "core/boot.nix")
    (configLib.moduleImport "desktop/desktop-gnome.nix")
    (configLib.moduleImport "applications/desktop-firefox.nix")
    (configLib.moduleImport "services/sys-ssh.nix")
  ];
}
```

### Module Structure

Each module should follow this template:

```nix
# modules/<category>/<prefix>-<n>.nix
#
# Brief description
#
# Detailed description
#
# Dependencies: core/nix.nix, services/web-nginx.nix
# Optional: services/mon-monitoring.nix
{ pkgs, lib, config, ... }:

{
  # Direct configuration - no options
  services.myservice = {
    enable = true;
    # Configuration here
  };
}
```

## 🎯 Best Practices

1. **Direct Configuration**: Modules apply settings immediately when imported
2. **No Options**: Avoid `mkOption`/`mkEnableOption` patterns
3. **Document Dependencies**: List required modules in the header
4. **Single Purpose**: Each module handles one specific functionality
5. **Self-Contained**: Modules should work independently
6. **Use Variants**: Create separate modules for different configurations

## 🔀 Module Variants

Different configurations are implemented as separate modules:

```
services/
├── nginx.nix              # Basic nginx
├── nginx-ssl.nix          # Nginx with SSL
├── nginx-proxy.nix        # Nginx as reverse proxy
└── nginx-production.nix   # Production-ready nginx
```

## 📚 Documentation

For more information, see:
- [MODULE_ORGANIZATION.md](../docs/MODULE_ORGANIZATION.md) - Complete organization guide
- [NAMING_CONVENTIONS.md](../docs/NAMING_CONVENTIONS.md) - Naming standards
- [MODULE_TEMPLATE.md](../docs/MODULE_TEMPLATE.md) - Module template and patterns

## ⚠️ Important Notes

- Modules directly configure the system when imported
- There are no enable/disable options
- Configuration is controlled by which modules you import
- Dependencies must be explicitly imported by the host
- Use module variants for different configurations
