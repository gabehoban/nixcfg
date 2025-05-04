# Module Migration Report
Date: Sun May  4 09:44:07 AM EDT 2025

## Renamed Modules

- `services/ssh.nix` → `services/sys-ssh.nix`
- `services/github-runner.nix` → `services/dev-github-runner.nix`
- `services/web-nginx.nix` → `services/web-nginx.nix`
- `core/starship.nix` → `core/shell/starship.nix`
- `applications/app-remmina.nix` → `applications/desktop-remmina.nix`
- `services/plex.nix` → `services/media-plex.nix`
- `applications/app-discord.nix` → `applications/desktop-discord.nix`
- `desktop/desktop-stylix.nix` → `desktop/desktop-theme.nix`
- `core/zsh.nix` → `core/shell/zsh.nix`
- `services/sonarr.nix` → `services/media-sonarr.nix`
- `services/sabnzbd.nix` → `services/media-sabnzbd.nix`
- `applications/app-firefox.nix` → `applications/desktop-firefox.nix`
- `services/audio.nix` → `services/sys-audio.nix`
- `services/node-exporter.nix` → `services/mon-node-exporter.nix`
- `services/cloudflared.nix` → `services/web-cloudflared.nix`
- `services/bind.nix` → `services/net-bind.nix`
- `applications/app-gaming.nix` → `applications/game-collection.nix`
- `services/recyclarr.nix` → `services/media-recyclarr.nix`
- `services/radarr.nix` → `services/media-radarr.nix`
- `services/prowlarr.nix` → `services/media-prowlarr.nix`
- `services/zram.nix` → `services/sys-zram.nix`
- `network/firewall.nix` → `network/net-firewall.nix`
- `services/attic.nix` → `services/storage-attic.nix`
- `services/monitoring.nix` → `services/mon-monitoring.nix`
- `applications/app-1password.nix` → `applications/desktop-1password.nix`
- `applications/app-claude.nix` → `applications/desktop-claude.nix`
- `services/yubikey.nix` → `services/sec-yubikey.nix`
- `services/minio.nix` → `services/storage-minio.nix`
- `applications/app-zed.nix` → `applications/dev-zed.nix`
- `core/direnv.nix` → `core/shell/direnv.nix`

## Files with Updated Imports

- ``
