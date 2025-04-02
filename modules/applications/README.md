# Applications

This directory contains modules for configuring specific applications for the system.

## Modules

- `app-1password.nix`: Configures the 1Password password manager
- `app-claude.nix`: Sets up Claude AI assistant application
- `app-discord.nix`: Configures Discord messaging application
- `app-firefox.nix`: Firefox browser configuration with useful defaults
- `app-gaming.nix`: Gaming-related applications and utilities
- `app-zed.nix`: Zed code editor configuration

## Usage

Import application modules selectively in your host configuration or profile:

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/applications/app-firefox.nix
    ./modules/applications/app-1password.nix
  ];
}
```

## Adding New Applications

When adding a new application module:

1. Create a new file named `app-[name].nix`
2. Follow the naming convention and structure of existing application modules
3. Include documentation comments at the top of the file
4. Isolate application-specific configuration
