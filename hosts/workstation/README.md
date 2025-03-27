# Workstation Configuration

This directory contains the NixOS configuration for the `workstation` host.

## Hardware Specifications

- **CPU**: AMD processor
- **GPU**: AMD graphics card
- **Network**: Realtek r8125 2.5G network card (requires custom driver)
- **Storage**: NVMe SSD with ZFS filesystem

## Key Features

- **ZFS on Root**: Using disko for declarative disk partitioning
- **Stateless Setup**: Includes impermanence with root filesystem rollback on boot
- **Desktop Environment**: GNOME with custom styling via stylix
- **User Configuration**: For user `gabehoban`

## Directory Structure

- `default.nix`: Main configuration entry point
- `hardware/`: Hardware-specific configurations
  - `default.nix`: Combined hardware configuration
  - `disks/`: ZFS and filesystem configurations
  - `network/`: Network hardware drivers

## Deployment

To build and deploy this configuration:

```bash
nixos-rebuild switch --flake .#workstation
```

For installation with disko (caution - will erase disk):

```bash
sudo ./scripts/install-with-disko
```