# NixOS Configuration Architecture

This document explains the architecture, design patterns, and organization of this NixOS configuration repository.

## Project Structure

```
nixcfg/
├── flake.nix                # Main flake file, defines inputs and outputs
├── flake.lock               # Locked versions of inputs
├── hosts/                   # System configurations for specific hosts
│   ├── sekio/               # Raspberry Pi GPS/NTP server
│   └── workstation/         # Desktop workstation
├── images/                  # System image building logic
├── lib/                     # Common library functions
├── modules/                 # Reusable NixOS modules
│   ├── applications/        # User applications like browsers, etc.
│   ├── core/                # Core system functionality
│   ├── desktop/             # Desktop environment modules
│   ├── hardware/            # Hardware-specific modules
│   ├── network/             # Networking modules including firewall
│   ├── services/            # Service configurations
│   └── users/               # User account configurations
├── overlays/                # Nixpkgs overlays
├── parts/                   # Flake-parts modules
├── pkgs/                    # Custom packages
├── profiles/                # Pre-composed groups of modules
└── secrets/                 # Encrypted secrets with agenix
```

## Key Design Patterns

### 1. Module Structure

All modules follow a consistent pattern:

- **Options Definition**: Each module defines its options in a structured way, with clear types and documentation
- **Configuration Implementation**: Based on the defined options
- **Dependencies**: Explicitly defined through imports and assertions

Example:
```nix
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.someModule;
in
{
  # Options definition
  options.modules.someModule = {
    enable = mkEnableOption (mdDoc "some module functionality");
    # Other options...
  };

  # Implementation
  config = mkIf cfg.enable {
    # Actual implementation...
    
    # Define dependencies through assertions
    assertions = [
      {
        assertion = config.someOtherModule.enable;
        message = "someModule requires someOtherModule to be enabled";
      }
    ];
  };
}
```

### 2. Flake Structure

We use `flake-parts` to organize our flake outputs into modular components:

- Each part focuses on a specific aspect (packages, nixos-configs, devshells, etc.)
- Parts are combined in the main flake.nix

### 3. Firewall Configuration

The network firewall implementation uses a zone-based approach:

- Traffic is classified into zones based on interfaces, subnets, etc.
- Rules define how traffic can flow between zones
- Consistent rule pattern ensures readability and maintainability

Example:
```nix
modules.network.firewall = {
  enable = true;
  zones = {
    trusted = {
      interfaces = [ "eth0" ];
      ipv4Addresses = [ "192.168.1.0/24" ];
    };
  };
  rules = {
    ssh = {
      from = [ "trusted" ];
      to = [ "fw" ];
      allowedTCPPorts = [ 22 ];
    };
  };
};
```

### 4. Hardware Configuration

Hardware-specific configurations are abstracted into modules:

- CPU-specific optimizations (AMD, Intel)
- GPU drivers and configurations
- Platform-specific settings (Raspberry Pi, etc.)

### 5. Service Patterns

Services follow a pattern focusing on:

- Reliability: Auto-recovery, dependency tracking
- Security: Proper permissions, isolation
- Performance: Resource limits, scheduling priorities

Example for critical services:
```nix
systemd.services.criticalService = {
  serviceConfig = {
    MemoryLimit = "100M";
    CPUWeight = 90;
    IOWeight = 90;
    OOMScoreAdjust = -900;
    Restart = "on-failure";
    RestartSec = "10s";
  };
};
```

## Security Model

The repository implements a layered security approach:

1. **Kernel Hardening**: Comprehensive sysctl settings and kernel parameters
2. **Network Security**: Zone-based firewall with fine-grained rules
3. **Service Isolation**: Proper systemd confinement settings for all services
4. **SSH Hardening**: Modern cryptography and restrictive settings
5. **Access Control**: AppArmor profiles where applicable
6. **Auditing**: System auditing for critical operations

## Performance Optimizations

Performance is optimized at multiple levels:

1. **Memory Management**: Fine-tuned VM settings, ZRAM, and earlyoom
2. **I/O Optimization**: Storage-specific I/O schedulers and parameters
3. **Process Scheduling**: Critical services given scheduling priority
4. **Service Resources**: Memory limits and CPU/IO weights

## Extending the Configuration

### Adding a New Host

To add a new host:

1. Create a new directory under `hosts/`
2. Define hardware configuration in `hosts/newhost/hardware/`
3. Create a `default.nix` that imports needed modules
4. Add the host to `parts/nixos-configs.nix`

### Creating a New Module

To create a new module:

1. Start with the template in `modules/MODULE_TEMPLATE.nix`
2. Define options with proper types and documentation
3. Implement the configuration based on options
4. Add assertions for dependencies
5. Import the new module in appropriate host configurations

### Adding Custom Packages

To add a custom package:

1. Create a new file in `pkgs/all/`
2. Add the package to `pkgs/all/default.nix`
3. Add the package to `parts/packages.nix` if it should be an output

## Build and Deployment

The system supports several deployment methods:

1. **Local build**: Using `nixos-rebuild`
2. **Remote deployment**: Using `deploy-rs` through `nix run .#deploy`
3. **Image building**: Using `nix build .#images.sekio` (or other hosts)

## Maintenance Practices

To keep the system maintainable:

1. **Regular updates**: Keep flake inputs updated
2. **Testing**: Test changes in VM before deploying
3. **Documentation**: Keep module documentation up to date
4. **Consistency**: Follow established module patterns
5. **Modularity**: Keep modules focused on specific functionality