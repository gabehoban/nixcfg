# Deployment Guide

This document explains how to deploy NixOS configurations to different hosts using deploy-rs and nixos-rebuild.

## Overview

This repository supports multiple deployment methods:
1. **Local deployment** using `nixos-rebuild`
2. **Remote deployment** using `deploy-rs`
3. **Cross-architecture deployment** for ARM devices

## Prerequisites

- Nix with flakes enabled
- SSH access to target machines (for remote deployment)
- Rekeyed secrets for target hosts (run `nix run .#agenix-rekey` if needed)
- deploy-rs installed (`nix shell nixpkgs#deploy-rs`)

## Local Deployment

### Switching to a Configuration

```bash
# Apply workstation configuration
sudo nixos-rebuild switch --flake .#workstation

# Test configuration without switching
sudo nixos-rebuild test --flake .#workstation

# Build configuration without switching
sudo nixos-rebuild build --flake .#workstation
```

## Remote Deployment with deploy-rs

### Basic Usage

```bash
# Deploy to a specific host
deploy .#nuc-juno

# Deploy to multiple hosts
deploy .#nuc-juno .#nuc-luna

# Deploy to all configured hosts
deploy .

# Dry run (see what would be deployed)
deploy . --dry-run
```

### Deploy Configuration

The deployment settings are defined in `parts/deploy.nix`. Each host has:
- **hostname**: Target machine's address
- **fastConnection**: Whether to use fast deployment optimizations
- **remoteBuild**: Whether to build on the target machine
- **profiles**: System configurations to deploy

### Cross-Architecture Deployment

For ARM devices (like Raspberry Pi), builds are performed on x86_64 machines and deployed to the target:

```bash
# Build is done on the deploying machine, then copied to target
deploy .#rpi-host
```

The workstation is configured with `boot.binfmt.emulatedSystems = [ "aarch64-linux" ]` to enable cross-compilation.

## Deployment Workflow

### 1. Pre-deployment Checks

Before deploying:
1. Ensure all secrets are rekeyed for the target host (`nix run .#agenix-rekey`)
2. Verify SSH access to target host
3. Check that the target host is online
4. Review changes with `git diff`

### 2. Building

The deployment process will:
1. Evaluate the Nix expression
2. Build the system configuration
3. Create activation scripts
4. Prepare the deployment

### 3. Deployment

During deployment:
1. Configuration is copied to the target
2. Activation script runs
3. Services are restarted as needed
4. Bootloader is updated (if applicable)
5. Host decrypts its secrets using its SSH key

### 4. Post-deployment

After deployment:
1. Verify services are running correctly
2. Check system logs for errors
3. Test critical functionality
4. Verify secrets are properly decrypted (`systemctl status` for services using secrets)

## Troubleshooting

### Common Issues

#### SSH Connection Failures
```
Error: SSH connection failed
```
**Solution**:
- Check SSH key authentication
- Verify hostname/IP is correct
- Ensure target is reachable
- Check firewall rules

#### Build Failures
```
error: build of '/nix/store/...-nixos-system-...' failed
```
**Solution**:
- Review error message for specific issue
- Check for syntax errors in configuration
- Ensure all required inputs are available
- Try building locally first

#### Secret Decryption Failures
```
age: error: no identity matched any of the recipients
```
**Solution**:
- Ensure secrets are rekeyed for the host (`nix run .#agenix-rekey`)
- Verify host SSH public key matches `age.rekey.hostPubkey` in config
- Check that secrets have `rekeyFile` defined in their module
- Review the `/secrets/rekeyed/<hostname>/` directory contains the expected files

#### Activation Failures
```
error: activation script failed
```
**Solution**:
- Check activation script logs
- Look for permission issues
- Verify all required services can start
- Check for port conflicts

### Remote Build Issues

For systems with limited resources:
1. Enable remote builds on a powerful machine
2. Configure the target to use the build machine
3. Or use `remoteBuild = false` in deploy configuration

## Rollback Procedures

### Immediate Rollback

```bash
# On the target machine
sudo nixos-rebuild switch --rollback

# Or boot into previous generation
# Select previous generation from bootloader menu
```

### Using deploy-rs Rollback

```bash
# Rollback to previous deployment
deploy .#hostname --rollback
```

## Best Practices

1. **Test First**: Always test configurations before deploying to production
2. **Incremental Changes**: Deploy small changes frequently
3. **Monitor Logs**: Watch system logs during deployment
4. **Backup First**: Ensure backups are current before major changes
5. **Document Changes**: Keep a changelog of deployments

## Host-Specific Notes

### Workstation
- Primary development machine
- Can build for all architectures
- Used as build host for other systems

### NUC Hosts (juno, luna, titan)
- Homelab servers
- Remote deployment recommended
- May require specific firewall rules

### Raspberry Pi Hosts
- ARM architecture (aarch64)
- Always built on x86_64 and deployed
- May have longer deployment times

## Advanced Deployment Scenarios

### Staging Deployments

1. Create a staging configuration
2. Test on staging environment
3. Deploy to production

### Blue-Green Deployments

1. Deploy to secondary hosts
2. Verify functionality
3. Switch traffic to new deployment
4. Keep old deployment as fallback

### Canary Deployments

1. Deploy to a subset of hosts
2. Monitor for issues
3. Gradually roll out to all hosts

## Monitoring Deployments

- Check systemd service status
- Monitor system logs
- Verify network connectivity
- Check resource utilization

## Emergency Procedures

### System Won't Boot

1. Boot from previous generation
2. Analyze boot logs
3. Fix configuration issue
4. Redeploy

### Network Connectivity Lost

1. Use console access if available
2. Boot into rescue mode
3. Fix network configuration
4. Restore connectivity

### Services Failing

1. Check service logs
2. Verify configuration
3. Check dependencies
4. Restart affected services

## Related Documentation

- [SECRETS.md](./SECRETS.md) - Secret management for deployments
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture overview
- [ADDING_HOSTS.md](./ADDING_HOSTS.md) - How to add new hosts
