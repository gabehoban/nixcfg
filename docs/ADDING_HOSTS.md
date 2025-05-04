# Adding New Hosts

This guide explains how to add new hosts to the NixOS configuration.

## Overview

Adding a new host involves:
1. Creating host configuration files
2. Setting up hardware configuration
3. Configuring secrets
4. Adding deployment configuration
5. Testing and deploying

## Step-by-Step Guide

### 1. Create Host Directory Structure

```bash
mkdir -p hosts/new-hostname/hardware/disks
```

### 2. Create Main Configuration

Create `hosts/new-hostname/default.nix`:

```nix
# hosts/new-hostname/default.nix
{
  configLib,
  inputs,
  ...
}:
{
  networking.hostName = "new-hostname";

  imports = [
    # External module integrations
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko

    # Hardware configuration
    (configLib.moduleImport "hardware/hw-cpu-intel.nix")  # or hw-cpu-amd.nix
    (configLib.moduleImport "network/default.nix")

    # Host-specific hardware
    ./hardware

    # Choose a profile
    (configLib.profileImport "server/homelab.nix")  # or desktop/gnome.nix

    # Additional services
    (configLib.moduleImport "services/ssh.nix")

    # User configuration
    (configLib.moduleImport "users/gabehoban.nix")
  ];

  # Host-specific settings
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3..."; # Get from ssh-keyscan

  system.stateVersion = "24.11";
}
```

### 3. Configure Hardware

Create `hosts/new-hostname/hardware/default.nix`:

```nix
# hosts/new-hostname/hardware/default.nix
{
  modulesPath,
  configLib,
  ...
}:
{
  imports = [
    ./boot.nix
    ./disks
    ./filesystems.nix
    # Add hardware scan results
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Hardware-specific settings
  hardware.enableRedistributableFirmware = true;
}
```

Create `hosts/new-hostname/hardware/boot.nix`:

```nix
# hosts/new-hostname/hardware/boot.nix
{
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];

    kernelModules = [ "kvm-intel" ];  # or kvm-amd

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
```

### 4. Configure Disk Layout

Create `hosts/new-hostname/hardware/disks/default.nix`:

```nix
# hosts/new-hostname/hardware/disks/default.nix
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";  # Adjust for your disk
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
```

### 5. Add to Flake Configuration

Edit `parts/nixos-configs.nix` to add your host:

```nix
{
  flake = {
    nixosConfigurations = {
      # ... existing hosts ...

      new-hostname = inputs.nixpkgs.lib.nixosSystem {
        modules = [ ../hosts/new-hostname ];
        specialArgs = {
          inherit inputs;
          configLib = import ../lib { inherit lib; };
        };
      };
    };
  };
}
```

### 6. Configure Deployment

Edit `parts/deploy.nix` to add deployment configuration:

```nix
{
  flake = {
    deploy = {
      nodes = {
        # ... existing nodes ...

        new-hostname = {
          hostname = "new-hostname.local";  # or IP address
          fastConnection = true;
          remoteBuild = false;  # true if host has good resources
          profiles = {
            system = {
              user = "root";
              path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.new-hostname;
            };
          };
        };
      };
    };
  };
}
```

### 7. Set Up Secrets

1. **Get the host's SSH public key**:
   ```bash
   ssh-keyscan -t ed25519 new-hostname.local
   ```

2. **Add to host configuration**:
   ```nix
   # In hosts/new-hostname/default.nix
   age.rekey.hostPubkey = "ssh-ed25519 AAAAC3...";
   ```

3. **Rekey all secrets for the new host**:
   ```bash
   # Run agenix-rekey to create host-specific encrypted secrets
   nix run .#agenix-rekey
   ```

4. **Verify rekeyed secrets**:
   ```bash
   # Check that secrets were created for the new host
   ls -la secrets/rekeyed/new-hostname/
   ```

5. **Commit the rekeyed secrets**:
   ```bash
   git add secrets/rekeyed/new-hostname/
   git commit -m "Add rekeyed secrets for new-hostname"
   ```

### 8. Initial Deployment

1. **Generate hardware configuration** (if on existing system):
   ```bash
   nixos-generate-config --show-hardware-config > hardware-config.nix
   ```

2. **Test the configuration**:
   ```bash
   nix flake check
   nixos-rebuild build --flake .#new-hostname
   ```

3. **Deploy**:
   ```bash
   # For local deployment
   sudo nixos-rebuild switch --flake .#new-hostname

   # For remote deployment
   deploy .#new-hostname
   ```

## Host Types

### Desktop Workstation

For desktop systems, use the GNOME profile:

```nix
imports = [
  (configLib.profileImport "desktop/gnome.nix")
];
```

Include:
- Desktop environment
- Audio services
- User applications
- Graphics drivers

### Server

For servers, use the homelab profile:

```nix
imports = [
  (configLib.profileImport "server/homelab.nix")
];
```

Include:
- Monitoring
- Network services
- Remote access
- Minimal GUI (if any)

### Build Host

For build servers, use the build-host profile:

```nix
imports = [
  (configLib.profileImport "server/build-host.nix")
];
```

Include:
- Enhanced Nix settings
- Cross-compilation support
- Build cache configuration

## Special Configurations

### Raspberry Pi / ARM Devices

For ARM devices:

1. Use appropriate hardware modules
2. Configure cross-compilation on build host
3. Set `remoteBuild = false` in deploy configuration

### Virtual Machines

For VMs:

1. Use appropriate disk configuration
2. Include VM guest tools
3. Configure network appropriately

### Impermanence

To enable impermanence:

```nix
{
  impermanence.enable = true;

  # Configure persistent paths as needed
  environment.persistence."/persist" = {
    directories = [
      "/var/log"
      "/var/lib"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
```

## Checklist

Before deploying a new host:

- [ ] Hardware configuration is complete
- [ ] Disk layout is configured
- [ ] Network settings are correct
- [ ] SSH access is configured
- [ ] Host SSH public key is added to configuration (`age.rekey.hostPubkey`)
- [ ] Secrets are rekeyed for the host (`nix run .#agenix-rekey`)
- [ ] Rekeyed secrets are committed to Git
- [ ] Host is added to flake
- [ ] Deployment configuration is added
- [ ] Configuration builds successfully
- [ ] Test deployment completed

## Troubleshooting

### Common Issues

1. **Hardware not detected**
   - Run `nixos-generate-config` on the target
   - Check kernel modules are loaded
   - Verify firmware packages are included

2. **Boot failures**
   - Check disk configuration matches hardware
   - Verify bootloader settings
   - Check UEFI/BIOS settings

3. **Network issues**
   - Verify network interface names
   - Check firewall configuration
   - Test connectivity from the host

4. **Secret decryption failures**
   - Ensure host SSH public key is correct in `age.rekey.hostPubkey`
   - Verify secrets are rekeyed (`nix run .#agenix-rekey`)
   - Check rekeyed secrets exist in `/secrets/rekeyed/<hostname>/`
   - Ensure services reference secrets with `rekeyFile` directive

## Best Practices

1. **Start Simple**: Begin with minimal configuration
2. **Test Locally**: Build and test before remote deployment
3. **Document Changes**: Add comments for host-specific settings
4. **Use Profiles**: Leverage existing profiles for common setups
5. **Version Control**: Commit configuration before deployment

## Examples

### Example: Adding a NUC Server

```bash
# 1. Create structure
mkdir -p hosts/nuc-venus/hardware/disks

# 2. Copy and modify from existing NUC
cp -r hosts/nuc-juno/* hosts/nuc-venus/
# Edit files as needed

# 3. Update flake
# Edit parts/nixos-configs.nix

# 4. Configure deployment
# Edit parts/deploy.nix

# 5. Deploy
deploy .#nuc-venus
```

### Example: Adding a Workstation

```bash
# 1. Create structure
mkdir -p hosts/desktop/hardware/disks

# 2. Use workstation as template
cp -r hosts/workstation/* hosts/desktop/
# Modify for specific hardware

# 3. Update configurations
# Edit as needed

# 4. Deploy locally
sudo nixos-rebuild switch --flake .#desktop
```

## Related Documentation

- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture
- [DEPLOYMENT.md](./DEPLOYMENT.md) - Deployment procedures
- [SECRETS.md](./SECRETS.md) - Secret management
