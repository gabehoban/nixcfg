# NixOS Modules

This directory contains modular NixOS configurations organized by functionality. Each module represents a specific functionality or configuration aspect.

## Flattened Module Pattern

All modules in this system follow the **"flattened module pattern"**. This means that modules apply their configuration directly when imported, rather than requiring options to be set elsewhere.

```nix
# modules/category/module-name.nix
#
# Brief description of the module's purpose
{ config, lib, pkgs, ... }:

{
  # Direct implementation - applied when the module is imported
  service.example.enable = true;
  
  # Conditional configuration when needed
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

### Legacy vs. Flattened Pattern

Some modules maintain the legacy options pattern for backward compatibility or host-specific customization. These modules use a hybrid approach:

```nix
# Hybrid pattern - flattened with optional customization
let
  # Default values with fallback if options aren't set
  enabled = config.modules.example.enable or true;
  setting = config.modules.example.setting or "default";
in
{
  # Options for customization
  options.modules.example = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable example functionality";
    };
    # Other options...
  };
  
  # Direct implementation (flattened)
  # Only applies configuration conditionally if required
  config = lib.mkIf enabled {
    # Implementation...
  };
}
```

## Directory Structure

```
modules/
├── applications/    - User applications (browsers, editors, etc.)
├── core/            - Core system functionality (boot, nix, shell, etc.)
├── desktop/         - Desktop environments and related tools
├── hardware/        - Hardware-specific configurations
├── network/         - Networking and firewall configurations
├── services/        - System services and daemons
└── users/           - User account configurations
```

## Module Categories

### Applications

Modules for specific user-facing applications:

- `app-1password.nix` - 1Password password manager
- `app-claude.nix` - Claude AI assistant
- `app-discord.nix` - Discord chat application
- `app-firefox.nix` - Firefox web browser
- `app-gaming.nix` - Gaming-related applications
- `app-zed.nix` - Zed code editor

### Core

Modules for core system functionality:

- `boot.nix` - Boot configuration
- `direnv.nix` - direnv shell environment
- `git.nix` - Git configuration
- `impermanence.nix` - Ephemeral system state (persistent /nix only)
- `lib.nix` - Library functions
- `locale.nix` - System locale settings
- `nix.nix` - Nix package manager configuration
- `packages.nix` - Common system packages
- `secrets.nix` - System secrets management
- `starship.nix` - Starship prompt
- `zsh.nix` - ZSH shell

### Desktop

Modules for desktop environments:

- `desktop-fonts.nix` - Font configuration
- `desktop-gnome.nix` - GNOME desktop environment
- `desktop-stylix.nix` - System-wide theme with stylix

### Hardware

Modules for hardware-specific configurations:

- `hw-cpu-amd.nix` - AMD CPU optimizations
- `hw-gps.nix` - GPS device support
- `hw-gpu-amd.nix` - AMD GPU drivers and configuration
- `hw-platform-rpi.nix` - Raspberry Pi platform support

### Network

Modules for networking and connectivity:

- `basic.nix` - Basic network configuration
- `dns.nix` - DNS configuration
- `firewall.nix` - NFT-based firewall

### Services

Modules for system services and daemons:

- `audio.nix` - Audio configuration
- `chrony.nix` - NTP server/client
- `gps-ntp-tools.nix` - GPS/NTP related tools
- `gpsd.nix` - GPS daemon
- `monitoring.nix` - System monitoring (Prometheus, Grafana)
- `ssh.nix` - SSH server
- `yubikey.nix` - YubiKey support
- `zram.nix` - ZRAM compressed swap

### Users

Modules for user account configurations:

- `gabehoban.nix` - User account for Gabe Hoban

## Using Modules

Modules can be used in host configurations:

```nix
{ configLib, ... }:
{
  imports = [
    (configLib.moduleImport "core/boot.nix")
    (configLib.moduleImport "desktop/desktop-gnome.nix")
    # Additional modules...
  ];
  
  # Enable specific modules
  modules.core.git.enable = true;
  modules.network.firewall.enable = true;
}
```

## Module Guidelines

Modules should be:

1. **Focused** - Each module should have a single, clear purpose
2. **Well-documented** - Include comprehensive documentation using `mdDoc`
3. **Atomic** - Be as independent as possible
4. **Minimal** - Have minimal dependencies on other modules
5. **Configurable** - Use options to make behavior customizable
6. **Robust** - Include proper error handling and assertions

Import modules selectively in your host configurations or profiles, rather than including entire directories by default.

## Module Templates and Patterns

For creating new modules, refer to:
- `MODULE_TEMPLATE.nix` - Basic module template
- `MODULE_PATTERNS.md` - Common module patterns
- `MODULE_STRUCTURE.md` - Module structure guidelines
- `hardware/HARDWARE_CONFIG_TEMPLATE.md` - Hardware module template
- `network/FIREWALL_PATTERNS.md` - Firewall configuration patterns
