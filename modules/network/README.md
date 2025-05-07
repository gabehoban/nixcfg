# Network Configuration Architecture

This directory contains network configuration for the NixOS systems in this repository. The architecture uses systemd-networkd as the primary network management system for improved stability and consistency.

## Design Principles

1. **Standardized Global Configuration** - Common network settings are defined once in `default.nix`:
   - IPv6 settings are applied consistently
   - DHCP client settings are standardized
   - Time synchronization is handled uniformly with chrony
   - Interface settings use consistent defaults

2. **Minimal Host-Specific Configuration** - Host network configurations are extremely concise:
   ```nix
   # Example minimal host network configuration
   imports = [
     (networkLib.makeNetworkInterface {
       interfaceName = "enp1s0";
     })
   ];
   ```

3. **DHCP-Only Addressing** - All network configurations use DHCP for:
   - IPv4 addressing
   - DNS server configuration
   - Default gateway information
   - Domain search paths

4. **Systemd-based Configuration** - Modern systemd tools are used:
   - systemd-networkd for network management
   - systemd-resolved for DNS resolution
   - chrony for precise time synchronization

## Network Configuration Structure

The network module is organized into these key components:

1. **default.nix** - Contains all standard network settings that apply to all hosts:
   - Basic network settings (networkd, DHCP, fallback DNS)
   - Global interface settings (DHCP, IPv6, link config)
   - Standard `10-default-settings` configuration for all interfaces
   - IPv6 sysctl parameters
   - Standardized time synchronization with chrony (enforced configuration)
   - Avahi and resolved configuration

2. **network.lib.nix** - Library of helper functions for host-specific customization:
   - `makeNetworkInterface`: Registers interfaces with NixOS (simplified)
   - `makeSharedNetworking`: Sets shared domain and host entries

3. **net-firewall.nix** - Firewall configuration that works across hosts

4. **host-config-template.nix** - Template for new host network configurations

## Using the Network Module

### Basic Host Setup

For all hosts, simply register their network interfaces:

```nix
# hosts/your-host/hardware/network.nix
{ config, lib, ... }:

let
  # Import the network library directly
  networkLib = import ../../modules/network/network.lib.nix { inherit lib; };
in
{
  imports = [
    (networkLib.makeNetworkInterface {
      interfaceName = "enp1s0"; # Change to match your host
    })
  ];
}
```

The actual network configuration is completely standardized with the global `10-default-settings` that applies to all interfaces. This ensures consistent networking behavior across all hosts.

### Adding New Hosts

To configure a new host:

1. Copy `host-config-template.nix` to your host's hardware directory
2. Rename to `network.nix`
3. Change the interface name to match your hardware
4. No other configuration is needed - all settings are standardized

## How It Works

1. **Global Defaults**: `default.nix` sets up a standardized network configuration with:
   - A single global `10-default-settings` that applies to all interfaces
   - Standard DHCP, IPv6, and link settings
   - System-wide chrony time synchronization

2. **Interface Registration**: Each host's `network.nix` simply:
   - Registers network interfaces with NixOS using `networking.interfaces`
   - No host-specific network settings are applied

This approach provides complete consistency across all hosts.

## Debugging Network Issues

See the original [NETWORK.md](NETWORK.md) for detailed debugging instructions.

## Best Practices & Important Notes

1. **Standardized Time Synchronization**:
   - All hosts use chrony for time synchronization with identical configuration
   - Standard settings are enforced with `lib.mkForce` to ensure consistency
   - Configuration includes:
     - NTP server pool (NixOS + Cloudflare)
     - Local network time serving (10.32.40.0/24)
     - Hardware timestamping for accurate synchronization
     - Optimized memory and performance settings
   - No per-host customization is permitted for time synchronization

2. **Interface Names**:
   - Always use the actual interface name (e.g., `eno1`) not the driver name
   - Check the interface name using `ip addr` or `networkctl` on the actual machine

3. **New Host Setup**:
   - Copy the `host-config-template.nix` to your host's `hardware/network.nix`
   - Customize the interface name and any needed settings
   - Most hosts need only the minimal configuration
