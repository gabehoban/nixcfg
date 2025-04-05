# Flattened Module Pattern

This document describes the "flattened module pattern" used in this NixOS configuration. This pattern simplifies configuration by making modules apply their configuration directly when imported, without requiring additional option settings.

## Standard Module Pattern (Options-Based)

The traditional NixOS module pattern uses options and conditional configuration:

```nix
# modules/example/feature.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.services.feature;
in {
  options.services.feature = {
    enable = lib.mkEnableOption "feature";
    setting1 = lib.mkOption { ... };
    setting2 = lib.mkOption { ... };
  };
  
  config = lib.mkIf cfg.enable {
    # Configuration applied conditionally when enabled
    environment.systemPackages = [ pkgs.feature ];
    systemd.services.feature = { ... };
  };
}
```

Host configuration must both import the module AND enable options:

```nix
# hosts/example/default.nix
{
  imports = [ 
    (configLib.moduleImport "example/feature.nix")
  ];
  
  # Need to explicitly enable and configure
  services.feature = {
    enable = true;
    setting1 = "value1";
    setting2 = "value2";
  };
}
```

## Flattened Module Pattern

The flattened module pattern eliminates the options layer:

```nix
# modules/example/feature.nix
{ config, lib, pkgs, ... }:

{
  # Configuration applied directly when imported
  environment.systemPackages = [ pkgs.feature ];
  systemd.services.feature = {
    enable = true;
    # Default settings...
  };
}
```

Host configuration only needs to import the module:

```nix
# hosts/example/default.nix
{
  imports = [
    # Just import the module, configuration applies automatically
    (configLib.moduleImport "example/feature.nix")
  ];
}
```

## Guidelines for Flattened Modules

1. **Use Sensible Defaults**: Hard-code reasonable defaults that work in most cases
2. **Use Conditional Logic**: For platform-specific settings, use `lib.mkIf` conditions
3. **Self-Contained**: Keep all related configuration in the same module
4. **Clear Documentation**: Add comments explaining what the module does
5. **Clear Prerequisites**: Document any modules that must be imported first

## When to Use Flattened Modules

Flattened modules are best for:

- Hardware support modules
- Basic service configurations
- Platform-specific optimizations
- Security hardening profiles
- Any feature that typically uses the same configuration across hosts

## When to Keep Options-Based Modules

Options-based modules are still useful for:

- Highly configurable services 
- Features that need many customization points
- Core system modules like networking
- Features that interact with multiple other subsystems

## Implementation Strategy

When implementing flattened modules:

1. Use descriptive file names following the project's naming conventions
2. Add clear comments about the module's purpose
3. Group related settings together within the module
4. Use `lib.mkIf` for conditional settings
5. Document required dependencies

## Example of Flattened Module: GPS Hardware

```nix
# modules/hardware/hw-gps.nix
{ config, lib, pkgs, ... }:

{
  # GPS hardware configuration for Raspberry Pi with PPS
  boot.kernelModules = [ "pps_gpio" "pps_core" ];
  
  services.gpsd = {
    enable = true;
    device = "/dev/ttyAMA0";
    autoStart = true;
  };
  
  # Additional configuration...
}
```