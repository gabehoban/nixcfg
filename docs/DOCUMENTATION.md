# Documentation Guide

This document serves as the central index for all documentation in this NixOS configuration repository.

## Documentation Index

### Core Documentation

1. **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System architecture and component relationships
2. **[MODULE_ORGANIZATION.md](./MODULE_ORGANIZATION.md)** - Module directory structure and categories
3. **[NAMING_CONVENTIONS.md](./NAMING_CONVENTIONS.md)** - Module naming standards and conventions
4. **[MODULE_TEMPLATE.md](./MODULE_TEMPLATE.md)** - Module coding standards and templates
5. **[DOCUMENTATION.md](./DOCUMENTATION.md)** - This documentation guide and standards

### Operational Guides

1. **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Deployment procedures using deploy-rs and nixos-rebuild
2. **[ADDING_HOSTS.md](./ADDING_HOSTS.md)** - Step-by-step guide for adding new hosts
3. **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - Common issues and diagnostic procedures
4. **[BACKUP_RECOVERY.md](./BACKUP_RECOVERY.md)** - Backup strategies and recovery procedures

### Security Documentation

1. **[SECRETS.md](./SECRETS.md)** - Secret management with agenix and YubiKey
   - YubiKey setup and configuration
   - Secret encryption and decryption
   - Recovery procedures

## Module Documentation Standards

Each module should include clear documentation in the form of header comments:

1. **Module name and path** (first line)
2. **One-line description** (brief summary of purpose)
3. **Detailed description** (for complex modules)
4. **Dependencies** (modules required for functionality)
5. **Section comments** for different parts of the implementation

Example:
```nix
# modules/services/chrony.nix
#
# NTP time synchronization service
#
# Configures Chrony for accurate timekeeping with optimized settings
# for network time synchronization.
{ pkgs, ... }:

{
  # Install chrony package
  environment.systemPackages = [ pkgs.chrony ];

  # Configure chrony service
  services.chrony = {
    # Use pool.ntp.org servers
    servers = [ /* ... */ ];

    # Additional configuration
    extraConfig = /* ... */;
  };
}
```

## Commenting Sections

For complex modules with multiple sections, use comment headers to separate logical parts:

```nix
# Firefox organizational policies
policies = {
  DisableAppUpdate = true;
  # ...more policies...
};

# Firefox preferences (about:config)
preferences = {
  # Hardware acceleration
  "media.ffmpeg.vaapi.enabled" = true;

  # Disable telemetry
  "datareporting.policy.dataSubmissionEnabled" = false;
  # ...more preferences...
};
```

## Implementation Notes

When a module has non-obvious behavior or important caveats, document these with clear comments:

```nix
# NOTE: This setting requires kernel 5.11+ for proper functionality
boot.kernelParams = [ "parameter=value" ];

# IMPORTANT: Order matters for these rules - more specific rules must come first
networking.firewall.extraRules = /* ... */;
```

## README Updates

When adding significant new functionality to the repository, update the README.md to reflect the changes:

1. Add to the Key Features section if applicable
2. Update the Project Structure if directory organization changes
3. Add any new examples or usage instructions
