# Profiles

Profiles combine multiple modules to provide a specific system configuration pattern that can be reused across different hosts.

## Organization

- `core/`: Essential profiles for basic system functionality
  - `minimal.nix`: Minimum viable system configuration
  - `desktop.nix`: Base desktop system configuration
  - `server.nix`: Base server system configuration

- `desktop/`: Desktop environment profiles
  - `gnome.nix`: GNOME desktop environment with reasonable defaults
  - `kde.nix`: KDE desktop environment with reasonable defaults

- `development/`: Development environment profiles
  - `default.nix`: Basic development tools
  - `web.nix`: Web development environment
  - `nix.nix`: Nix development environment

- `hardware/`: Hardware-specific profiles
  - `amd-desktop.nix`: Configuration for AMD desktop systems
  - `intel-laptop.nix`: Configuration for Intel laptop systems

## Usage

Profiles should combine related modules to provide a cohesive configuration for a specific use case. Each profile should:

1. Have a clear, specific purpose
2. Include only the necessary modules
3. Be well-documented
4. Have reasonable default settings

Import profiles in your host configurations to provide a baseline that can be customized as needed.
