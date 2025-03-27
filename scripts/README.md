# NixOS Configuration Scripts

This directory contains scripts for managing the NixOS configuration.

## Directory Structure

- `installation/`: Scripts for installing NixOS
  - `install-with-disko`: Install NixOS using disko for disk partitioning
- `maintenance/`: Scripts for maintaining the system
  - `update-system`: Update the system by pulling changes and rebuilding

## Installation Scripts

### install-with-disko

Installs NixOS using disko for disk partitioning:

```bash
./scripts/installation/install-with-disko <hostname> [username]
```

Arguments:
- `hostname`: The target host configuration to install
- `username`: The primary user (defaults to jon)

## Maintenance Scripts

### update-system

Updates the system by pulling the latest changes and rebuilding:

```bash
./scripts/maintenance/update-system [hostname]
```

Arguments:
- `hostname`: The target host configuration to update (defaults to current hostname)

## Adding New Scripts

When adding new scripts:

1. Place them in the appropriate subdirectory based on their purpose
2. Make sure they are executable (`chmod +x script-name`)
3. Include a descriptive header comment with usage instructions
4. Update this README with information about the script
