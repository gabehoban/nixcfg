# Gabe's NixOS Configuration

A modular, organized NixOS configuration repository with support for multiple hosts.

## Features

- Modular design with separation of concerns
- Support for multiple hosts/machines
- Impermanence support
- Common configurations shared across hosts
- Custom packages and overlays
- Installation scripts and tools

## Directory Structure

```
nixcfg/
├── flake.nix                # Main flake configuration
├── hosts/                   # Host-specific configurations
├── images/                  # NixOS installation images
├── lib/                     # Helper functions and utilities
├── overlays/                # Package overlays
├── pkgs/                    # Custom packages
└── scripts/                 # Utility scripts
```

## Quick Start

```bash
curl -L nix.norpie.dev | sh
```

## Installation

### Prerequisites

- NixOS installation media
- Internet connection
- Basic knowledge of disk partitioning

### Steps

1. Boot from a NixOS installation media
2. Clone this repository:
   ```bash
   git clone https://github.com/norpie/nixcfg.git
   cd nixcfg
   ```
3. Install using disko:
   ```bash
   ./scripts/installation/install-with-disko workstation
   ```

## Usage

### Building the System

```bash
# Rebuild and switch
sudo nixos-rebuild switch --flake .#workstation

# Build without switching
nix build .#nixosConfigurations.workstation.config.system.build.toplevel
```

### Creating Installation Media

```bash
# Build workstation ISO
nix build .#nixosConfigurations.iso-workstation.config.system.build.isoImage
```

### System Maintenance

Use the maintenance scripts to keep your system up-to-date:

```bash
./scripts/maintenance/update-system
```

## Adding a New Host

1. Create a new directory under `hosts/`:
   ```bash
   mkdir -p hosts/newhost/{hardware,default.nix}
   ```
2. Configure the host in `hosts/newhost/default.nix`
3. Add hardware configuration in `hosts/newhost/hardware/`
4. Add the host to `flake.nix`

## License

This project is licensed under the MIT License - see the LICENSE file for details.
