# Module Organization

This document explains the module organization structure and naming conventions used in this NixOS configuration.

## Design Philosophy

This project uses a **direct import** approach rather than an options-based system:
- Modules directly configure the system when imported
- No `mkOption` or `mkEnableOption` declarations
- Configuration is controlled by which modules are imported
- Conditional behavior is achieved through separate module variants

## Directory Structure

```
modules/
├── applications/       # User-facing applications
│   ├── desktop-*.nix   # GUI applications
│   ├── cli-*.nix       # Command-line tools
│   ├── dev-*.nix       # Development tools
│   └── game-*.nix      # Gaming applications
│
├── core/              # Essential system components
│   ├── boot.nix       # Boot configuration
│   ├── nix.nix        # Nix package manager settings
│   ├── security.nix   # System security settings
│   ├── secrets.nix    # Secret management (agenix)
│   └── shell/         # Shell environment
│       ├── zsh.nix    # Z shell configuration
│       ├── starship.nix # Shell prompt
│       └── direnv.nix   # Directory environments
│
├── desktop/           # Desktop environment components
│   ├── desktop-gnome.nix  # GNOME desktop
│   ├── desktop-fonts.nix  # Font configuration
│   └── desktop-theme.nix  # Theme management (Stylix)
│
├── hardware/          # Hardware-specific configurations
│   ├── hw-cpu-*.nix   # CPU optimizations
│   ├── hw-gpu-*.nix   # GPU drivers and settings
│   └── hw-*.nix       # Other hardware features
│
├── network/           # Network configuration
│   ├── basic.nix      # Core networking
│   ├── net-firewall.nix # Firewall rules
│   └── net-*.nix      # Network features
│
├── services/          # System and network services
│   ├── media-*.nix    # Media services (Plex, *arr)
│   ├── mon-*.nix      # Monitoring services
│   ├── storage-*.nix  # Storage services
│   ├── sys-*.nix      # System services
│   ├── web-*.nix      # Web services
│   ├── sec-*.nix      # Security services
│   ├── dev-*.nix      # Development services
│   └── net-*.nix      # Network services
│
└── users/             # User account configurations
    └── <username>.nix # Per-user settings
```

## Import Behavior

When a module is imported:
1. All configurations in the module are applied
2. No enable/disable options exist
3. The module should be self-contained
4. Dependencies must be explicitly imported

Example host configuration:
```nix
{
  imports = [
    # Import only what this host needs
    (configLib.moduleImport "core/boot.nix")
    (configLib.moduleImport "core/nix.nix")
    (configLib.moduleImport "desktop/desktop-gnome.nix")
    (configLib.moduleImport "applications/desktop-firefox.nix")
  ];
}
```

## Naming Conventions

### Prefix Guide

| Category | Prefix | Description | Examples |
|----------|--------|-------------|----------|
| Applications | `desktop-` | GUI applications | `desktop-firefox.nix` |
| Applications | `cli-` | Command-line tools | `cli-youtubedl.nix` |
| Applications | `dev-` | Development tools | `dev-zed.nix` |
| Applications | `game-` | Gaming applications | `game-steam.nix` |
| Core | none | Essential system modules | `boot.nix`, `nix.nix` |
| Desktop | `desktop-` | Desktop environment | `desktop-gnome.nix` |
| Hardware | `hw-` | Hardware configurations | `hw-cpu-amd.nix` |
| Network | `net-` | Network features | `net-firewall.nix` |
| Services | `media-` | Media services | `media-plex.nix` |
| Services | `mon-` | Monitoring services | `mon-prometheus.nix` |
| Services | `storage-` | Storage services | `storage-minio.nix` |
| Services | `sys-` | System services | `sys-ssh.nix` |
| Services | `web-` | Web services | `web-nginx.nix` |
| Services | `sec-` | Security services | `sec-yubikey.nix` |
| Services | `dev-` | Development services | `dev-github-runner.nix` |

### Naming Rules

1. **Use kebab-case**: All module names use lowercase with hyphens
2. **Be descriptive**: Names should clearly indicate purpose
3. **Use consistent prefixes**: Follow the prefix guide above
4. **Keep it concise**: Avoid overly long names

## Module Structure

Each module should follow this structure:
```nix
# modules/<category>/<prefix>-<n>.nix
#
# <Brief description>
#
# <Detailed description>
#
# Dependencies: <list required modules>
# Optional: <list optional enhancements>
{ pkgs, lib, config, ... }:

{
  # Direct configuration
  services.example = {
    enable = true;
    # ... settings
  };

  # Additional configuration
  environment.systemPackages = [ pkgs.example ];
}
```

## Module Categories

### Applications (`/modules/applications/`)

User-facing applications organized by interface type:
- Desktop applications (GUI)
- Command-line tools
- Development environments
- Gaming software

### Core (`/modules/core/`)

Essential system functionality:
- Boot process
- Package management
- Security framework
- Shell environment

### Desktop (`/modules/desktop/`)

Desktop environment components:
- Window managers/Desktop environments
- Font management
- Theme configuration
- Display settings

### Hardware (`/modules/hardware/`)

Hardware-specific optimizations:
- CPU configurations
- GPU drivers
- Platform-specific settings
- Hardware features (secure boot, etc.)

### Network (`/modules/network/`)

Network configuration and services:
- Basic networking
- Firewall rules
- VPN configurations
- Network features

### Services (`/modules/services/`)

System and network services categorized by function:
- Media services (streaming, downloading)
- Monitoring and observability
- Storage services
- System services
- Web services
- Security services
- Development services

### Users (`/modules/users/`)

User account configurations:
- Individual user settings
- Home directory management
- User-specific packages

## Best Practices

1. **Direct Configuration**: Modules configure the system directly when imported
2. **No Options**: Avoid mkOption/mkEnableOption patterns
3. **Clear Dependencies**: Document module dependencies in headers
4. **Single Purpose**: Each module should focus on one functionality
5. **Self-Contained**: Modules should work independently
6. **Variant Modules**: Create separate modules for different configurations

## Module Variants

Instead of conditional options, create module variants:

```
services/
├── nginx.nix              # Basic nginx
├── nginx-ssl.nix          # Nginx with SSL defaults
└── nginx-proxy.nix        # Nginx as reverse proxy
```

Each variant imports and extends as needed:
```nix
# nginx-ssl.nix
{
  imports = [ ./web-nginx.nix ];

  services.nginx = {
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    # ... SSL-specific settings
  };
}
```

## Adding New Modules

When adding a new module:

1. Choose the appropriate category directory
2. Follow naming conventions for that category
3. Create direct configuration (no options)
4. Document dependencies clearly
5. Test the module works when imported

## Module Dependencies

Dependencies should be:
1. Explicitly documented in module headers
2. Imported by the host configuration
3. Not automatically imported by modules

Example dependency documentation:
```nix
# modules/services/web-app.nix
#
# Web application service
#
# Dependencies: services/web-nginx.nix, core/secrets.nix
```

## Anti-Patterns

Avoid these patterns:
1. Using `mkOption` or `mkEnableOption`
2. Conditional configuration within modules
3. Auto-importing dependencies
4. Global state modifications
5. Complex enable/disable logic

## Migration from Options-Based Modules

To convert option-based modules:
1. Remove all option declarations
2. Replace conditional config with direct settings
3. Create separate variants for different configurations
4. Update documentation to list dependencies
5. Test direct imports work correctly

## Example Module Patterns

### Basic Service
```nix
{ pkgs, ... }:
{
  services.myservice = {
    enable = true;
    package = pkgs.myservice;
    settings = {
      port = 8080;
      logLevel = "info";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
```

### Service with Variants
```nix
# base-service.nix
{ pkgs, ... }:
{
  services.myservice = {
    enable = true;
    package = pkgs.myservice;
  };
}

# service-with-monitoring.nix
{
  imports = [ ./base-service.nix ];

  services.myservice.settings = {
    metrics.enable = true;
    metrics.port = 9090;
  };

  networking.firewall.allowedTCPPorts = [ 9090 ];
}
```

### Application with Configuration
```nix
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.myapp ];

  environment.etc."myapp/config.json".text = builtins.toJSON {
    theme = "dark";
    autoUpdate = false;
  };
}
```

This approach ensures:
- Simple, predictable module behavior
- Clear configuration through imports
- Easy to understand what's enabled
- No hidden conditional logic
