# Module Template and Coding Standards

This document provides a template and coding standards for creating modules in this NixOS configuration repository.

## Module Template

All new modules should follow this template structure:

```nix
# modules/<category>/<prefix>-<n>.nix
#
# <Brief one-line description>
#
# <Detailed multi-line description explaining the purpose, key features,
# and any important implementation details>
#
# Dependencies: <list required modules, e.g., core/nix.nix, services/sys-ssh.nix>
# Optional: <list optional dependencies that enhance functionality>
{ pkgs, lib, config, ... }:

{
  # Direct configuration - no options
  services.myService = {
    enable = true;
    # ... other settings
  };

  # Additional configuration as needed
  environment.systemPackages = [ pkgs.myPackage ];

  # Any other required system configuration
}
```

## Coding Standards

### 1. Documentation

* Every module MUST have a header comment with:
  * File path following naming conventions
  * One-line description
  * Detailed multi-line description (for complex modules)
  * Required dependencies
  * Optional dependencies (if applicable)

### 2. File Organization

* Use appropriate directory for the module's category
* Follow naming conventions strictly:
  * `desktop-*.nix` for GUI applications
  * `cli-*.nix` for command-line tools
  * `dev-*.nix` for development tools
  * `sys-*.nix` for system services
  * See [MODULE_ORGANIZATION.md](./MODULE_ORGANIZATION.md) for complete list
* Group related files in subdirectories when appropriate

### 3. Implementation Style

* Directly declare settings without conditional wrappers
* Group related settings together with comments
* Prefer declarative configuration over imperative
* Document any side effects or interactions with other modules
* If a module needs conditional behavior, make separate modules (e.g., `service.nix` and `service-minimal.nix`)

### 4. Code Formatting

* Use 2-space indentation
* Keep imports minimal - only include what's needed
* Use consistent naming for similar concepts
* Add explanatory comments for complex settings
* Follow Nix formatting conventions

## Examples

### Basic Service Module

```nix
# modules/services/sys-example.nix
#
# Example system service
#
# Provides a basic system service with logging and monitoring
#
# Dependencies: core/nix.nix
# Optional: services/mon-monitoring.nix (for metrics export)
{ pkgs, lib, config, ... }:

{
  # Service configuration
  systemd.services.example = {
    description = "Example Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.example}/bin/example --port 8080";
      WorkingDirectory = "/var/lib/example";
      User = "example";
      Group = "example";
      Restart = "always";
      RestartSec = "10s";
    };
  };

  # Create service user
  users.users.example = {
    isSystemUser = true;
    group = "example";
    home = "/var/lib/example";
  };

  users.groups.example = {};

  # Ensure data directory exists
  systemd.tmpfiles.rules = [
    "d /var/lib/example 0750 example example -"
  ];

  # Open firewall port
  networking.firewall.allowedTCPPorts = [ 8080 ];
}
```

### Desktop Application Module

```nix
# modules/applications/desktop-myapp.nix
#
# MyApp desktop application
#
# Configures MyApp with custom settings and desktop integration
#
# Dependencies: desktop/desktop-gnome.nix
# Optional: core/secrets.nix (for API keys)
{ pkgs, lib, config, ... }:

{
  # Install the application
  environment.systemPackages = [ pkgs.myapp ];

  # Application configuration
  environment.etc."myapp/config.json".text = builtins.toJSON {
    theme = "auto";
    updateChannel = "stable";
    telemetry = false;
  };

  # Desktop integration
  xdg.mime.defaultApplications = {
    "x-scheme-handler/myapp" = "myapp.desktop";
  };

  # Additional desktop file customization
  xdg.desktopEntries.myapp = {
    name = "MyApp";
    exec = "myapp %U";
    icon = "myapp";
    categories = [ "Office" "Network" ];
  };
}
```

### Hardware Configuration Module

```nix
# modules/hardware/hw-gpu-nvidia.nix
#
# NVIDIA GPU configuration
#
# Configures NVIDIA proprietary drivers and related settings
#
# Dependencies: none
# Optional: desktop/desktop-gnome.nix (for Wayland configuration)
{ config, lib, pkgs, ... }:

{
  # Enable NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  # Hardware acceleration
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false; # Use proprietary drivers
  };

  # OpenGL configuration
  hardware.graphics = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Environment variables
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
```

### Module with Secrets

```nix
# modules/services/web-myapi.nix
#
# MyAPI web service
#
# Configures a web API service with secret management
#
# Dependencies: core/secrets.nix, services/web-nginx.nix
# Optional: services/mon-monitoring.nix
{ config, lib, pkgs, ... }:

{
  # Secret configuration
  age.secrets.myapi-token = {
    rekeyFile = ../../secrets/myapi-token.age;
    owner = "myapi";
    group = "myapi";
  };

  # Service configuration
  systemd.services.myapi = {
    description = "My API Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.myapi}/bin/myapi";
      EnvironmentFile = config.age.secrets.myapi-token.path;
      User = "myapi";
      Group = "myapi";
    };
  };

  # Nginx reverse proxy
  services.nginx.virtualHosts."api.example.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:3000";
      proxyWebsockets = true;
    };
  };
}
```

## Best Practices

1. **No Options**: Modules should directly configure the system without options
2. **Clear Dependencies**: Document which modules must be imported together
3. **Single Purpose**: Each module should do one thing well
4. **Idempotent**: Modules should be safe to import multiple times
5. **No Side Effects**: Avoid global state modifications
6. **Documentation**: Always include purpose and dependencies

## Common Patterns

### Conditional Features Based on Other Modules

Instead of runtime conditionals, create separate modules:

```nix
# modules/services/myservice.nix - Basic service
{ ... }:
{
  services.myservice = {
    enable = true;
    # Basic configuration
  };
}

# modules/services/myservice-with-nginx.nix - Service with nginx
{ ... }:
{
  imports = [ ./myservice.nix ];

  services.nginx.virtualHosts."myservice.example.com" = {
    # Nginx configuration
  };
}
```

### Service with State

```nix
# modules/services/stateful-service.nix
{ config, ... }:
{
  systemd.services.stateful = {
    # Service configuration
  };

  # State persistence for impermanent systems
  environment.persistence."/persist" = lib.mkIf (config.environment.persistence.enable or false) {
    directories = [
      { directory = "/var/lib/stateful"; user = "stateful"; group = "stateful"; mode = "0750"; }
    ];
  };
}
```

### Desktop Application with Custom Configuration

```nix
# modules/applications/desktop-browser.nix
{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;

    # Directly set preferences
    preferences = {
      "browser.startup.homepage" = "https://example.com";
      "privacy.donottrackheader.enabled" = true;
    };

    # Add extensions
    policies.Extensions.Install = [
      "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
    ];
  };
}
```

## Module Categories Reference

| Category | Directory | Prefix | Purpose |
|----------|-----------|--------|---------|
| Applications | `/applications/` | `desktop-`, `cli-`, `dev-`, `game-` | User applications |
| Core | `/core/` | none | Essential system modules |
| Desktop | `/desktop/` | `desktop-` | Desktop environment |
| Hardware | `/hardware/` | `hw-` | Hardware configurations |
| Network | `/network/` | `net-` | Network settings |
| Services | `/services/` | `sys-`, `web-`, `media-`, `mon-`, `storage-`, `sec-`, `dev-` | System services |
| Users | `/users/` | none | User configurations |

See [MODULE_ORGANIZATION.md](./MODULE_ORGANIZATION.md) for complete naming convention details.

## Anti-Patterns to Avoid

1. **Using mkOption**: This project doesn't use options-based configuration
2. **Runtime conditionals**: Create separate modules instead
3. **Global options**: Each module should be self-contained
4. **Complex enable logic**: If something needs toggling, make it a separate module
5. **Circular dependencies**: Modules should have clear dependency order

## Migration Guide

When converting option-based modules:

1. Remove all `options.*` declarations
2. Replace `config = mkIf cfg.enable` with direct configuration
3. Move conditional features to separate modules
4. Update documentation to list dependencies clearly
5. Test that the module works when imported directly
