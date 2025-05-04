# Module Naming Conventions

This document establishes clear naming conventions for modules to ensure consistency and discoverability across the NixOS configuration.

## Design Philosophy

This project uses a **direct import** approach:
- Modules directly configure the system when imported
- No options-based configuration (no `mkOption` or `mkEnableOption`)
- Configuration control is achieved by choosing which modules to import
- Conditional behavior is implemented through separate module variants

## General Rules

1. Use kebab-case for all module files (lowercase with hyphens)
2. Use descriptive names that clearly indicate the module's purpose
3. Apply consistent prefixes within categories
4. Keep names concise but meaningful
5. Create variants for different configurations (e.g., `nginx.nix` vs `nginx-ssl.nix`)

## Module Categories and Prefixes

### Applications (`/modules/applications/`)

Applications should be categorized by their primary interface type:

- **Desktop Applications**: `desktop-<name>.nix`
  - Examples: `desktop-firefox.nix`, `desktop-discord.nix`, `desktop-1password.nix`

- **Command-line Tools**: `cli-<name>.nix`
  - Examples: `cli-youtubedl.nix`, `cli-git.nix`, `cli-tmux.nix`

- **Development Tools**: `dev-<name>.nix`
  - Examples: `dev-zed.nix`, `dev-vscode.nix`, `dev-direnv.nix`

- **Gaming Applications**: `game-<name>.nix`
  - Examples: `game-steam.nix`, `game-lutris.nix`

### Core System (`/modules/core/`)

Core modules should use no prefix, just descriptive names:
- Examples: `boot.nix`, `nix.nix`, `security.nix`, `locale.nix`

### Desktop Environment (`/modules/desktop/`)

Desktop components should use the `desktop-` prefix:
- Examples: `desktop-gnome.nix`, `desktop-fonts.nix`, `desktop-theme.nix`
- Note: `desktop-stylix.nix` → `desktop-theme.nix` (more generic)

### Hardware (`/modules/hardware/`)

Hardware modules should use the `hw-` prefix with component type:
- CPU: `hw-cpu-<vendor>.nix` (e.g., `hw-cpu-amd.nix`)
- GPU: `hw-gpu-<vendor>.nix` (e.g., `hw-gpu-nvidia.nix`)
- Platform: `hw-platform-<name>.nix` (e.g., `hw-platform-rpi.nix`)
- Features: `hw-<feature>.nix` (e.g., `hw-secureboot.nix`)

### Network (`/modules/network/`)

Network modules should use the `net-` prefix where appropriate:
- Basic networking: `basic.nix` (core functionality)
- Specific features: `net-<feature>.nix`
- Examples: `net-firewall.nix`, `net-vpn.nix`, `net-wifi.nix`

### Services (`/modules/services/`)

Services should be categorized by their function:

- **System Services**: `sys-<name>.nix`
  - Examples: `sys-ssh.nix`, `sys-audio.nix`, `sys-zram.nix`

- **Web Services**: `web-<name>.nix`
  - Examples: `web-nginx.nix`, `web-cloudflared.nix`

- **Media Services**: `media-<name>.nix`
  - Examples: `media-plex.nix`, `media-sonarr.nix`, `media-radarr.nix`

- **Monitoring**: `mon-<name>.nix`
  - Examples: `mon-prometheus.nix`, `mon-node-exporter.nix`, `mon-grafana.nix`

- **Storage Services**: `storage-<name>.nix`
  - Examples: `storage-minio.nix`, `storage-nfs.nix`

- **Security Services**: `sec-<name>.nix`
  - Examples: `sec-yubikey.nix`, `sec-fail2ban.nix`

### Users (`/modules/users/`)

User modules should use the username directly:
- Examples: `gabehoban.nix`, `admin.nix`

## Proposed Reorganization

Based on these conventions, here's the proposed reorganization:

### Applications
```
applications/
├── desktop-1password.nix    # was: app-1password.nix
├── desktop-claude.nix       # was: app-claude.nix
├── desktop-discord.nix      # was: app-discord.nix
├── desktop-firefox.nix      # was: app-firefox.nix
├── desktop-remmina.nix      # was: app-remmina.nix
├── dev-zed.nix             # was: app-zed.nix
├── game-collection.nix      # was: app-gaming.nix
└── cli-youtubedl.nix       # unchanged
```

### Core
```
core/
├── boot.nix
├── certificates.nix
├── locale.nix
├── nix.nix
├── packages.nix
├── secrets.nix
├── security.nix
└── shell/
    ├── zsh.nix             # moved to subdirectory
    ├── starship.nix        # moved to subdirectory
    └── direnv.nix          # moved to subdirectory
```

### Desktop
```
desktop/
├── desktop-gnome.nix       # unchanged
├── desktop-fonts.nix       # unchanged
└── desktop-theme.nix       # was: desktop-stylix.nix
```

### Network
```
network/
├── basic.nix
├── net-firewall.nix        # was: firewall.nix
└── default.nix
```

### Services
```
services/
├── media-plex.nix          # was: plex.nix
├── media-sonarr.nix        # was: sonarr.nix
├── media-radarr.nix        # was: radarr.nix
├── media-prowlarr.nix      # was: prowlarr.nix
├── media-sabnzbd.nix       # was: sabnzbd.nix
├── media-recyclarr.nix     # was: recyclarr.nix
├── mon-monitoring.nix      # was: monitoring.nix
├── mon-node-exporter.nix   # was: node-exporter.nix
├── storage-attic.nix       # was: attic.nix
├── storage-minio.nix       # was: minio.nix
├── sys-audio.nix           # was: audio.nix
├── sys-ssh.nix             # was: ssh.nix
├── sys-zram.nix            # was: zram.nix
├── web-nginx.nix           # was: nginx.nix
├── web-cloudflared.nix     # was: cloudflared.nix
├── net-bind.nix            # was: bind.nix
├── dev-github-runner.nix   # was: github-runner.nix
└── sec-yubikey.nix         # was: yubikey.nix
```

## Migration Plan

1. Create new module files with proper names
2. Update imports in all dependent files
3. Remove old module files
4. Update documentation to reflect new structure
5. Test all configurations to ensure nothing breaks

## Benefits

1. **Consistency**: All modules follow predictable patterns
2. **Discoverability**: Easy to find modules by category and function
3. **Scalability**: Clear rules for adding new modules
4. **Organization**: Better grouping of related functionality
5. **Maintenance**: Easier to understand module relationships

## Module Variants

Since this project uses direct imports instead of options, different configurations are implemented as separate module variants:

### Variant Naming Patterns

1. **Base Module**: The simplest configuration
   - Example: `nginx.nix` (basic nginx server)

2. **Feature Variants**: Base module + specific features
   - Example: `nginx-ssl.nix` (nginx with SSL settings)
   - Example: `nginx-proxy.nix` (nginx as reverse proxy)

3. **Environment Variants**: Optimized for specific contexts
   - Example: `nginx-production.nix` (production-ready nginx)
   - Example: `nginx-development.nix` (nginx with debug options)

4. **Integration Variants**: Module with specific integrations
   - Example: `nginx-with-monitoring.nix` (nginx + prometheus metrics)

### Variant Guidelines

1. Start with the base module name
2. Append variant descriptors with hyphens
3. Keep variant names descriptive but concise
4. Document what differentiates each variant
5. Variants should import and extend base modules when appropriate

## Implementation Checklist

- [ ] Create this naming convention document
- [ ] Get approval for proposed changes
- [ ] Create migration script to rename files
- [ ] Update all import statements
- [ ] Test each host configuration
- [ ] Update documentation
- [ ] Create PR with all changes
