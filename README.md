# ✨ My NixOS Config! ✨

[![ci-badge](https://img.shields.io/static/v1?label=Built%20with&message=nix&color=blue&style=flat&logo=nixos&link=https://nixos.org&labelColor=111212)](https://gvolpe.com)
[![Build](https://github.com/gabehoban/nixcfg/actions/workflows/build.yml/badge.svg)](https://github.com/gabehoban/nixcfg/actions/workflows/build.yml)
[![Validate](https://github.com/gabehoban/nixcfg/actions/workflows/validate.yml/badge.svg)](https://github.com/gabehoban/nixcfg/actions/workflows/validate.yml)
[![Update](https://github.com/gabehoban/nixcfg/actions/workflows/update.yml/badge.svg)](https://github.com/gabehoban/nixcfg/actions/workflows/update.yml)
[![Dependencies](https://github.com/gabehoban/nixcfg/actions/workflows/dependencies.yml/badge.svg)](https://github.com/gabehoban/nixcfg/actions/workflows/dependencies.yml)

This repository contains my NixOS configurations, along with custom modules and packages. It is modular, declarative, and tailored for multi-device setups.

## 🧩 Project Structure

```
nixcfg/
├── hosts/         # Machine-specific configurations (currently featuring workstation)
├── modules/       # Atomic functionality units organized by purpose
├── profiles/      # Pre-composed collections of modules for quick setup
├── lib/           # Helper functions that make Nix life easier
├── overlays/      # Package customizations
└── pkgs/          # Custom package definitions
```

### Key Features

- **AMD Hardware Support** - Optimized for AMD CPUs and GPUs
- **GNOME Desktop** - Sleek, customized GNOME environment with carefully selected extensions
- **Impermanence** - System state persistence where you want it, fresh boots where you don't
- **Application Suite** - Curated selection including Firefox, Discord, 1Password, and more
- **Secure Boot** - Lanzaboote integration for secure system startup

## 🚀 Getting Started

### Build and Deploy

```bash
# Switch to this configuration (replace workstation with your hostname)
nixos-rebuild switch --flake .#workstation
```

### Customizing for Your Machine

1. Create a new directory in `hosts/` with your machine's name
2. Set up hardware configs in `hosts/your-machine/hardware/`
3. Create a `default.nix` that imports the modules and profiles you need
4. Add your machine to `flake.nix` under `nixosConfigurations`

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
