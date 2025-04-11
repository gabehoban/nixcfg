# ✨ My NixOS Config! ✨

[![ci-badge](https://img.shields.io/static/v1?label=Built%20with&message=nix&color=blue&style=flat&logo=nixos&link=https://nixos.org&labelColor=111212)](https://nixos.org)
[![Build](https://github.com/gabehoban/nixcfg/actions/workflows/build.yml/badge.svg)](https://github.com/gabehoban/nixcfg/actions/workflows/build.yml)
[![Update](https://github.com/gabehoban/nixcfg/actions/workflows/update.yml/badge.svg)](https://github.com/gabehoban/nixcfg/actions/workflows/update.yml)
[![Dependencies](https://github.com/gabehoban/nixcfg/actions/workflows/dependencies.yml/badge.svg)](https://github.com/gabehoban/nixcfg/actions/workflows/dependencies.yml)

This repository contains my NixOS configurations, along with custom modules and packages. It is modular, declarative, and tailored for multi-device setups.

## 🧩 Project Structure

```
nixcfg/
├── hosts/         # Machine-specific configurations (workstation and sekio)
├── modules/       # Atomic functionality units organized by purpose
├── profiles/      # Pre-composed collections of modules for quick setup
├── lib/           # Helper functions that make Nix life easier
├── overlays/      # Package customizations
└── pkgs/          # Custom package definitions
```

### Key Features

- **Multi-architecture Support** - Optimized for both x86_64 and aarch64 systems
- **AMD Hardware Support** - Optimized for AMD CPUs and GPUs
- **Raspberry Pi Support** - Optimized for Raspberry Pi 4 with GPS/NTP capabilities
- **GNOME Desktop** - Sleek, customized GNOME environment with carefully selected extensions
- **Impermanence** - System state persistence where you want it, fresh boots where you don't
- **Remote Deployment** - Build on powerful machines, deploy to resource-constrained devices
- **Application Suite** - Curated selection including Firefox, Discord, 1Password, and more
- **Secure Boot** - Lanzaboote integration for secure system startup (see modules/core/boot.nix)

## 🚀 Getting Started

### Build and Deploy

```bash
# Switch to workstation configuration
nixos-rebuild switch --flake .#workstation

# Deploy to sekio using colmena
colmena apply --on rpi-sekio
```

### Remote Deployment

This repository uses [Colmena](https://github.com/zhaofengli/colmena) for remote deployment, which builds the system on the more powerful workstation and deploys to the target machines.

```bash
# Build and deploy sekio configuration
colmena apply --on rpi-sekio

# Apply to all nodes
colmena apply

# Build without deploying
colmena build

# Deploy to specific nodes
colmena apply --on nuc-juno nuc-luna
```

### Customizing for Your Machine

1. Create a new directory in `hosts/` with your machine's name
2. Set up hardware configs in `hosts/your-machine/hardware/`
3. Create a `default.nix` that imports the modules and profiles you need
4. Add your machine to `flake.nix` under `nixosConfigurations`
5. Optionally add your machine to the Colmena configuration in parts/colmena.nix

## 🧰 Working with Modules

Modules are the building blocks of this configuration. They're organized by function:

- **core/** - Essential system settings (boot, shell, locales)
- **hardware/** - Hardware-specific configurations (CPU, GPU, networking)
- **desktop/** - UI environments and customizations
- **services/** - System services (audio, SSH, YubiKey)
- **applications/** - User-facing apps
- **users/** - User account configurations

Adding a new module is as simple as creating a .nix file in the appropriate directory and importing it where needed!

## 🏗️ Architecture Philosophy

1. **Composable** - Mix and match modules to build exactly what you need
2. **Discoverable** - Clear organization makes finding and understanding configs easy
3. **Maintainable** - Small, focused modules with clear purposes
4. **Reproducible** - Same config = same result, every time
5. **Upgradable** - Flakes pin inputs for deterministic builds while making updates straightforward

## 📜 License

This project is licensed under the MIT License - feel free to adapt it for your own systems!
