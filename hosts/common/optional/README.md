# NixOS Optional Modules

This directory contains optional modules that can be selectively imported into NixOS configurations. The modules are organized into categories to maintain a clean and structured approach.

## Directory Structure

- `applications/` - User applications and programs
  - `browser/` - Web browsers like Firefox
  - `communication/` - Communication tools like Discord
  - `development/` - Development tools like Zed editor
  - `gaming/` - Gaming-related software like Steam
  - `productivity/` - Productivity tools like Claude
  - `system/` - System utilities like 1Password
  - `index.nix` - Aggregates all application modules

- `desktop/` - Desktop environments and theming
  - `environments/` - Desktop environments like GNOME
  - `theme/` - Theming engines like Stylix
  - `fonts.nix` - Font configurations

- `hardware/` - Hardware-specific configurations
  - `amd.nix` - AMD CPU and GPU optimizations

- `services/` - System services
  - `ai.nix` - AI-related services like Ollama
  - `audio.nix` - Audio services
  - `media.nix` - Media services
  - `nas.nix` - Network storage services
  - `ssh.nix` - SSH configuration
  - `yubikey.nix` - YubiKey support
  - `zram.nix` - Compressed RAM configuration

## Usage

To cherry-pick specific modules:

```nix
{
  imports = [
    (configLib.relativeToRoot "hosts/common/optional/applications/browser/firefox.nix")
    (configLib.relativeToRoot "hosts/common/optional/desktop/environments/gnome.nix")
  ];
}
```

## Adding New Modules

When adding new modules, follow these guidelines:

1. Place the module in the appropriate category directory
2. Update the corresponding `default.nix` to include the new module
3. Follow the existing naming conventions
4. Document any special requirements or dependencies
