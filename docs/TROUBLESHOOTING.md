# Troubleshooting Guide

This guide helps diagnose and resolve common issues with the NixOS configuration.

## Common Issues

### Build Failures

#### Syntax Errors

**Symptoms**:
```
error: syntax error, unexpected '}'
```

**Solution**:
1. Check for missing semicolons
2. Verify bracket matching
3. Use `nix flake check` to validate
4. Run `nixfmt` to format code

#### Missing Attributes

**Symptoms**:
```
error: attribute 'foo' missing
```

**Solution**:
1. Verify all required options are set
2. Check module imports are correct
3. Ensure dependencies are available
4. Review module documentation

#### Infinite Recursion

**Symptoms**:
```
error: infinite recursion encountered
```

**Solution**:
1. Check for circular dependencies
2. Review module imports
3. Use `lib.mkForce` or `lib.mkOverride` if needed
4. Break circular references

### Deployment Issues

#### SSH Connection Failures

**Symptoms**:
```
Error: SSH connection failed
```

**Solution**:
1. Verify SSH key authentication:
   ```bash
   ssh -v user@host
   ```
2. Check hostname/IP is correct
3. Ensure firewall allows SSH (port 22)
4. Verify target host is online

#### Remote Build Failures

**Symptoms**:
```
error: cannot build on 'ssh://host': error setting up ssh connection
```

**Solution**:
1. Check SSH agent is running
2. Verify SSH keys are loaded
3. Test SSH connection manually
4. Check remote host has Nix installed

#### Activation Script Failures

**Symptoms**:
```
error: activation script snippet 'xyz' failed
```

**Solution**:
1. Check systemd journal for details:
   ```bash
   journalctl -xe
   ```
2. Verify file permissions
3. Check for port conflicts
4. Review service dependencies

### Secret Management Issues

#### YubiKey Not Detected

**Symptoms**:
```
age: error: yubikey plugin: failed to open YubiKey
```

**Solution**:
1. Ensure YubiKey is properly inserted
2. Check USB permissions:
   ```bash
   sudo usermod -a -G plugdev $USER
   ```
3. Restart age-plugin-yubikey
4. Try different USB port

#### Decryption Failures

**Symptoms**:
```
age: error: no identity matched any of the recipients
```

**Solution**:
1. Verify correct YubiKey is being used
2. Check if secrets need rekeying:
   ```bash
   cd secrets/
   agenix -r
   ```
3. Ensure public key is in secrets configuration
4. Verify YubiKey PIN is correct

#### Permission Denied on Secrets

**Symptoms**:
```
Permission denied: /run/agenix/secret-name
```

**Solution**:
1. Check secret file permissions in configuration
2. Verify user/group settings for the secret
3. Ensure service user has access rights
4. Review systemd service configuration

### Service Issues

#### Service Won't Start

**Symptoms**:
```
systemctl status service-name
● service-name.service - Description
   Loaded: loaded
   Active: failed
```

**Solution**:
1. Check service logs:
   ```bash
   journalctl -u service-name
   ```
2. Verify configuration syntax
3. Check dependencies are running
4. Review port availability
5. Test configuration manually if possible

#### Port Conflicts

**Symptoms**:
```
Address already in use
```

**Solution**:
1. Identify conflicting service:
   ```bash
   sudo ss -tulpn | grep :PORT
   ```
2. Stop conflicting service
3. Change port in configuration
4. Check for duplicate service definitions

### Boot Issues

#### System Won't Boot

**Symptoms**: System hangs or kernel panic during boot

**Solution**:
1. Boot previous generation from bootloader
2. Check boot logs:
   ```bash
   journalctl -b -1  # Previous boot
   ```
3. Verify disk configuration
4. Check initrd has required modules

#### Secure Boot Failures

**Symptoms**:
```
Secure Boot violation
```

**Solution**:
1. Verify secure boot keys are enrolled
2. Check if bootloader is signed correctly
3. Review lanzaboote configuration
4. Temporarily disable secure boot to diagnose

### Hardware Issues

#### Missing Drivers

**Symptoms**: Hardware not working or not detected

**Solution**:
1. Check kernel modules are loaded:
   ```bash
   lsmod | grep module_name
   ```
2. Verify firmware packages are included
3. Check hardware compatibility
4. Review dmesg for errors:
   ```bash
   dmesg | grep -i error
   ```

#### GPU Issues

**Symptoms**: No graphics acceleration or display issues

**Solution**:
1. Verify correct GPU drivers are installed
2. Check Xorg logs:
   ```bash
   cat /var/log/Xorg.0.log
   ```
3. Test with different driver versions
4. Check kernel parameters

### Network Issues

#### No Network Connection

**Symptoms**: Cannot reach network

**Solution**:
1. Check interface status:
   ```bash
   ip addr
   ip link
   ```
2. Verify network configuration
3. Test DNS resolution:
   ```bash
   dig example.com
   ```
4. Check firewall rules

#### Firewall Blocking Services

**Symptoms**: Service accessible locally but not remotely

**Solution**:
1. Review firewall configuration
2. Open required ports:
   ```nix
   networking.firewall.allowedTCPPorts = [ 80 443 ];
   ```
3. Check service binding address
4. Test with firewall temporarily disabled

## Diagnostic Commands

### System Information

```bash
# NixOS version
nixos-version

# System configuration
nixos-rebuild dry-build

# Hardware information
lshw -short
lspci
lsusb

# Disk usage
df -h
du -sh /nix/store
```

### Nix Diagnostics

```bash
# Check flake
nix flake check
nix flake show

# Evaluate configuration
nix eval .#nixosConfigurations.hostname.config.system.build.toplevel

# Build specific attribute
nix build .#nixosConfigurations.hostname.config.system.build.toplevel

# Show derivation
nix show-derivation /nix/store/...
```

### Service Diagnostics

```bash
# Service status
systemctl status service-name
systemctl list-units --failed

# Service logs
journalctl -u service-name
journalctl -f  # Follow logs

# Process information
ps aux | grep service
htop
```

### Network Diagnostics

```bash
# Network interfaces
ip addr show
ip route show

# DNS testing
dig example.com
nslookup example.com

# Connection testing
ping 8.8.8.8
traceroute example.com
curl -v https://example.com
```

## Recovery Procedures

### Boot Recovery

1. Select previous generation from bootloader
2. Boot with minimal configuration:
   ```
   boot.kernelParams = [ "emergency" ];
   ```
3. Use rescue mode if available
4. Boot from NixOS installation media

### Configuration Rollback

```bash
# List generations
sudo nix-env --list-generations -p /nix/var/nix/profiles/system

# Switch to previous generation
sudo nixos-rebuild switch --rollback

# Switch to specific generation
sudo nix-env -p /nix/var/nix/profiles/system --switch-generation 42
```

### Emergency Shell Access

1. Add to kernel parameters: `init=/bin/sh`
2. Boot into emergency mode
3. Mount filesystems manually
4. Fix configuration issues
5. Rebuild system

## Performance Troubleshooting

### Slow Builds

**Solution**:
1. Enable more cores:
   ```nix
   nix.settings.cores = 0;  # Use all cores
   ```
2. Use binary caches
3. Enable remote builds
4. Check disk I/O performance

### High Memory Usage

**Solution**:
1. Run garbage collection:
   ```bash
   sudo nix-collect-garbage -d
   ```
2. Optimize store:
   ```bash
   sudo nix-store --optimise
   ```
3. Check for memory leaks
4. Review service configurations

## Getting Help

### Resources

1. [NixOS Manual](https://nixos.org/manual/nixos/stable/)
2. [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
3. [NixOS Discourse](https://discourse.nixos.org/)
4. [NixOS Wiki](https://nixos.wiki/)

### Debug Mode

Enable debug output:
```bash
# Nix operations
export NIX_DEBUG=1

# Systemd services
systemctl edit service-name
# Add: Environment="DEBUG=1"
```

### Reporting Issues

When reporting issues, include:
1. Full error message
2. Relevant configuration snippets
3. System information (`nixos-version`)
4. Steps to reproduce
5. What you've already tried

## Prevention

### Best Practices

1. Test changes in VM first
2. Keep backups of working configurations
3. Use version control effectively
4. Document custom configurations
5. Monitor system resources

### Regular Maintenance

1. Run garbage collection weekly
2. Update flake inputs regularly
3. Review system logs
4. Check for security updates
5. Test backups regularly

## Related Documentation

- [DEPLOYMENT.md](./DEPLOYMENT.md) - Deployment procedures
- [SECRETS.md](./SECRETS.md) - Secret management
- [ADDING_HOSTS.md](./ADDING_HOSTS.md) - Adding new hosts
