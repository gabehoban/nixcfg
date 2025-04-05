# Module Implementation Patterns

This document describes the common patterns and conventions used in module implementation across this NixOS configuration.

## Flattened Module Pattern

All modules in this system follow the "flattened module" pattern. This means that modules apply their configuration directly when imported, rather than exposing options that need to be set elsewhere.

### What is a Flattened Module?

A flattened module:
- Applies configuration directly when imported
- Does not define options
- Uses conditional logic when needed
- Is simpler and more direct than traditional NixOS modules

### Flattened vs. Traditional Modules

#### Traditional NixOS Module Pattern (AVOID):

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.myModule;
in
{
  # Define options
  options.modules.myModule = {
    enable = lib.mkEnableOption "My feature";
    setting1 = lib.mkOption { ... };
    setting2 = lib.mkOption { ... };
  };

  # Apply configuration conditionally based on options
  config = lib.mkIf cfg.enable {
    # Implementation using cfg.setting1, cfg.setting2, etc.
  };
}
```

#### Flattened Module Pattern (PREFERRED):

```nix
{ config, lib, pkgs, ... }:

# Direct configuration with no options
{
  # Directly applied when imported
  services.myService.enable = true;
  environment.systemPackages = with pkgs; [ package1 package2 ];
  
  # Use conditional logic when needed
  services.dependent = lib.mkIf (config.services.required.enable or false) {
    enable = true;
  };
}
```

### Benefits of Flattened Modules

1. **Simplicity**: Clearer relationship between importing a module and what it does
2. **Reduced Boilerplate**: No need for options and conditional logic in most modules
3. **Improved Readability**: Host configurations are easier to understand
4. **Reduced Repetition**: No need to both import a module and enable its functionality

### Module Structure

All modules follow this structure:

```nix
# modules/category/module-name.nix
#
# Brief description of the module's purpose
{ config, lib, pkgs, ... }:

{
  # Direct configuration (applied when imported)
  services.something.enable = true;
  
  # Conditional configuration when needed
  services.dependent = lib.mkIf (config.services.required.enable or false) {
    enable = true;
  };
}
```

### Header Documentation

Every module should include a header comment that explains:
- The module's path
- A brief description of the module's purpose
- Any special considerations or dependencies

Example:
```nix
# modules/hardware/hw-cpu-amd.nix
#
# AMD CPU configuration and optimizations
```

## Naming Conventions

Modules follow consistent naming conventions based on their category:

- **Applications**: `app-[name].nix` (e.g., `app-firefox.nix`)
- **Hardware**: `hw-[component]-[vendor].nix` (e.g., `hw-cpu-amd.nix`)
- **Desktop**: `desktop-[environment].nix` (e.g., `desktop-gnome.nix`)
- **Users**: Named after the username (e.g., `gabehoban.nix`)
- **Services**: Named after the service (e.g., `ssh.nix`, `audio.nix`)
- **Core**: Named after the core functionality (e.g., `boot.nix`, `locale.nix`)

## Code Organization

Modules should organize code into logical sections with section headers:

```nix
#
# Section name
#
```

Example from `app-firefox.nix`:
```nix
#
# Firefox organizational policies
#
policies = {
  # Settings here
};

#
# Firefox preferences (about:config)
#
preferences = {
  # Preferences here
};
```

## Common Implementation Patterns

### Hardware Configuration

Hardware modules typically include:
- Microcode updates
- Kernel module configuration
- Kernel parameters
- Firmware settings

Example from `hw-cpu-amd.nix`:
```nix
hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

boot.blacklistedKernelModules = [
  "k10temp"
  "acpi-cpufreq"
];
boot.extraModulePackages = [ config.boot.kernelPackages.zenpower ];
boot.kernelModules = [ "zenpower" ];
boot.kernelParams = [ "amd_pstate=active" ];
```

### Application Configuration

Application modules typically include:
- Application installation and configuration
- Default settings
- Extensions or plugins
- Data persistence configuration

### Service Configuration

Service modules typically include:
- Service enablement
- Configuration options
- Firewall rules
- User permissions

### User Configuration

User modules typically include:
- User account definition
- Group memberships
- Shell configuration
- Home directory setup
- User-specific applications

## Best Practices

1. **Use mkDefault for Overridable Settings**: Use `lib.mkDefault` for settings that should be overridable by more specific configurations.

2. **Group Related Settings**: Keep related settings together in logical groups.

3. **Include Comments for Non-Obvious Settings**: Add comments explaining non-obvious settings or workarounds.

4. **Isolate Module Functionality**: Each module should have a clear, focused purpose without unnecessary dependencies.

5. **Use Conditional Configuration**: Use `lib.mkIf` and `lib.mkMerge` for conditional configuration based on system properties.

6. **Persistence Configuration**: When a module requires persistent data across reboots with impermanence, include appropriate persistence configuration as shown in the Firefox example.