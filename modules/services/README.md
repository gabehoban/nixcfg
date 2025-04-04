# Services

This directory contains modules for configuring system services and daemons.

## Modules

- `ai.nix`: Configuration for AI-related services
- `audio.nix`: Audio subsystem configuration (PipeWire, PulseAudio, etc.)
- `chrony.nix`: NTP server/client with GPS integration for precise timekeeping
- `gpsd.nix`: GPS daemon configuration for GPS hardware
- `gps-ntp-tools.nix`: GPS and NTP related tools for monitoring and troubleshooting
- `ssh.nix`: SSH server and client configuration
- `yubikey.nix`: YubiKey authentication and security services
- `zram.nix`: ZRAM compressed memory configuration

## Usage

Import service modules in your host configuration or profile:

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/services/audio.nix
    ./modules/services/ssh.nix
  ];
}
```

## Adding New Services

When adding a new service module:

1. Create a new file for the service
2. Include clear documentation about the service's purpose and options
3. Use NixOS service options where available
4. Configure reasonable defaults while allowing customization
5. Ensure services only start when explicitly enabled
