# Backup and Recovery Guide

This document outlines backup strategies and recovery procedures for NixOS systems managed by this configuration.

## Overview

NixOS provides inherent recoverability through:
- Declarative configuration
- Immutable system state
- Generation management
- Reproducible builds

However, additional backup strategies are needed for:
- Stateful data
- Secrets
- User data
- Service databases

## What to Backup

### Critical Components

1. **Configuration Repository**
   - The entire `nixcfg` repository
   - Including `.git` directory for history
   - All flake inputs and lock file

2. **Secrets**
   - Encrypted age files
   - YubiKey backup (physical)
   - Secret configuration files

3. **Stateful Data**
   - Service databases
   - User home directories
   - Application data
   - Persistent storage paths

4. **System State**
   - `/etc/machine-id`
   - SSH host keys
   - SSL certificates
   - Custom configurations outside Nix

## Backup Strategies

### Configuration Backup

The Git repository serves as the primary configuration backup:

```bash
# Push to multiple remotes
git remote add backup git@backup-server:nixcfg.git
git push backup main

# Create tagged releases
git tag -a v1.0.0 -m "Stable release"
git push --tags
```

### Secrets Backup

#### YubiKey Backup

1. **Physical Backup**:
   - Keep spare YubiKey in secure location
   - Store in fireproof safe or safety deposit box

2. **Key Duplication**:
   ```bash
   # Set up backup YubiKey
   age-plugin-yubikey --identity

   # Add backup key to secrets configuration
   # Rekey all secrets
   agenix -r
   ```

3. **Recovery Information**:
   - Document YubiKey serial numbers
   - Store PIN in secure password manager
   - Keep public keys in multiple locations

### Data Backup

#### Automated Backups

Create a backup module for services:

```nix
# modules/services/backup.nix
{ config, lib, pkgs, ... }:
{
  services.borgbackup.jobs = {
    system = {
      paths = [
        "/home"
        "/var/lib"
        "/etc/nixos"
      ];
      repo = "ssh://backup@backup-server/backups/system";
      encryption.mode = "repokey-blake2";
      encryption.passCommand = "cat /run/agenix/backup-passphrase";
      compression = "auto,lzma";
      startAt = "daily";
      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
    };
  };
}
```

#### Manual Backup Commands

```bash
# Backup home directory
tar -czf home-backup.tar.gz /home/

# Backup service data
pg_dump database > database-backup.sql

# Backup Docker volumes
docker run --rm -v volume:/data -v $(pwd):/backup ubuntu tar czf /backup/volume-backup.tar.gz /data
```

### System State Backup

```bash
# Backup critical system files
sudo tar -czf system-state.tar.gz \
  /etc/machine-id \
  /etc/ssh/ssh_host_* \
  /var/lib/bluetooth \
  /var/lib/NetworkManager
```

## Recovery Procedures

### Configuration Recovery

#### From Git Repository

```bash
# Clone configuration
git clone https://github.com/username/nixcfg.git
cd nixcfg

# Restore specific version
git checkout v1.0.0

# Deploy configuration
sudo nixos-rebuild switch --flake .
```

#### From Backup

```bash
# Extract backup
tar -xzf nixcfg-backup.tar.gz
cd nixcfg

# Verify and deploy
nix flake check
sudo nixos-rebuild switch --flake .
```

### Secret Recovery

#### With Backup YubiKey

1. Insert backup YubiKey
2. Clone configuration repository
3. Deploy system normally
4. Secrets will decrypt automatically

#### Without YubiKey (Emergency)

If all YubiKeys are lost:

1. Generate new age keys
2. Restore secrets from secure backup
3. Re-encrypt with new keys
4. Update configuration
5. Deploy new system

### Data Recovery

#### From Borg Backup

```bash
# List backups
borg list ssh://backup@server/repo

# Restore specific files
borg extract ssh://backup@server/repo::archive-name path/to/file

# Restore entire backup
borg extract ssh://backup@server/repo::archive-name
```

#### From Manual Backups

```bash
# Restore home directory
tar -xzf home-backup.tar.gz -C /

# Restore database
psql database < database-backup.sql

# Restore Docker volume
docker run --rm -v volume:/data -v $(pwd):/backup ubuntu tar xzf /backup/volume-backup.tar.gz -C /
```

### System Recovery

#### Boot Previous Generation

1. Reboot system
2. Select previous generation from bootloader
3. Investigate issue
4. Fix configuration
5. Rebuild system

#### From Installation Media

1. Boot NixOS installation media
2. Mount system partitions:
   ```bash
   mount /dev/nvme0n1p2 /mnt
   mount /dev/nvme0n1p1 /mnt/boot
   ```
3. Restore configuration:
   ```bash
   cd /mnt/etc/nixos
   git clone https://github.com/username/nixcfg.git .
   ```
4. Rebuild system:
   ```bash
   nixos-install --flake /mnt/etc/nixos#hostname
   ```

### Disaster Recovery

#### Complete System Loss

1. **Prepare New Hardware**
   - Install NixOS minimal
   - Set up network access

2. **Restore Configuration**
   ```bash
   git clone https://github.com/username/nixcfg.git
   cd nixcfg
   ```

3. **Set Up Secrets**
   - Use backup YubiKey
   - Or restore from secure backup

4. **Deploy System**
   ```bash
   sudo nixos-rebuild switch --flake .#hostname
   ```

5. **Restore Data**
   - Restore from backups
   - Verify service functionality

## Backup Verification

### Regular Testing

1. **Monthly Verification**:
   ```bash
   # Test configuration deployment
   nixos-rebuild build --flake .

   # Verify backup integrity
   borg check ssh://backup@server/repo
   ```

2. **Quarterly Recovery Test**:
   - Deploy to test VM
   - Restore sample data
   - Verify services start
   - Test secret decryption

### Monitoring

Set up monitoring for backup jobs:

```nix
services.prometheus.exporters.borgbackup = {
  enable = true;
  repository = "ssh://backup@server/repo";
};

services.grafana.dashboards = [{
  name = "Backup Status";
  # ... dashboard configuration
}];
```

## Best Practices

### Backup Practices

1. **3-2-1 Rule**:
   - 3 copies of data
   - 2 different storage types
   - 1 offsite copy

2. **Encryption**:
   - Encrypt all backups
   - Use strong passphrases
   - Store keys securely

3. **Automation**:
   - Automate backup processes
   - Monitor backup status
   - Alert on failures

### Recovery Practices

1. **Documentation**:
   - Document all procedures
   - Keep recovery guides updated
   - Store documentation separately

2. **Testing**:
   - Regular recovery drills
   - Verify backup integrity
   - Update procedures as needed

3. **Access Control**:
   - Limit backup access
   - Use separate credentials
   - Audit access regularly

## Emergency Contacts

Create an emergency contact list:

```markdown
# Emergency Contacts

## Infrastructure
- Hosting Provider: +1-555-0123
- Domain Registrar: support@registrar.com

## Team
- Primary Admin: admin@example.com
- Backup Admin: backup@example.com

## Services
- Backup Provider: support@backup.com
- Security Team: security@example.com
```

## Recovery Checklist

### Pre-Recovery

- [ ] Identify failure scope
- [ ] Notify stakeholders
- [ ] Gather recovery resources
- [ ] Review recovery procedures

### During Recovery

- [ ] Follow documented procedures
- [ ] Document actions taken
- [ ] Communicate progress
- [ ] Verify each step

### Post-Recovery

- [ ] Verify system functionality
- [ ] Document lessons learned
- [ ] Update procedures
- [ ] Schedule post-mortem

## Automation Scripts

### Backup Script

```bash
#!/usr/bin/env bash
# backup.sh - Automated backup script

set -euo pipefail

# Configuration backup
git push backup main

# System state backup
sudo tar -czf /tmp/system-state.tar.gz \
  /etc/machine-id \
  /etc/ssh/ssh_host_*

# Upload to secure storage
rclone copy /tmp/system-state.tar.gz remote:backups/

# Clean up
rm /tmp/system-state.tar.gz

echo "Backup completed successfully"
```

### Recovery Script

```bash
#!/usr/bin/env bash
# recover.sh - Automated recovery script

set -euo pipefail

# Clone configuration
git clone https://github.com/username/nixcfg.git
cd nixcfg

# Deploy system
sudo nixos-rebuild switch --flake .#hostname

# Restore data
borg extract ssh://backup@server/repo::latest

echo "Recovery completed successfully"
```

## Related Documentation

- [DEPLOYMENT.md](./DEPLOYMENT.md) - Deployment procedures
- [SECRETS.md](./SECRETS.md) - Secret management
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Problem diagnosis
