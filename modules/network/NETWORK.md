# Network Configuration Documentation

## Overview

This document describes the network configuration for our NixOS hosts. We've implemented a systemd-networkd-based network configuration that provides stable IPv4 and IPv6 addressing.

## Architecture

The network configuration is structured as follows:

- **shared.nix**: Contains common network settings, host entries, and DNS settings
- **basic.nix**: Core networking setup using systemd-networkd
- **ipv6.nix**: IPv6-specific configuration optimized for stable addressing
- **net-firewall.nix**: Enhanced firewall configuration with proper IPv6 support
- **host-config.nix**: Template file for host-specific network configuration

## Network Design Principles

1. **Interface Consistency**: Each host defines its primary interface name as a module argument (`_module.args.primaryInterface`), which is used by other modules.

2. **Stable Addressing**:
   - IPv4: DHCP with consistent addressing provided by the router
   - IPv6: SLAAC with disabled privacy extensions for stable, predictable addresses

3. **Network Dependency Management**: Services requiring network connectivity correctly wait for network-online.target, which is signaled when interfaces are properly routed.

4. **Firewall Configuration**: Properly allows essential ICMPv6 traffic for IPv6 operation.

## Host Configuration

| Host | Primary Interface | Network Manager | IPv6 Privacy | Notes |
|------|------------------|-----------------|--------------|-------|
| nuc-titan | enp1s0 | systemd-networkd | Disabled | AMD-based NUC |
| nuc-luna | enp1s0 | systemd-networkd | Disabled | Intel-based NUC |
| nuc-juno | enp1s0 | systemd-networkd | Disabled | Intel-based NUC |
| workstation | eno1 | systemd-networkd | Disabled | Custom Realtek r8125 driver |

## IPv6 Configuration

Our IPv6 strategy uses:
- SLAAC for address assignment
- Router Advertisements for default gateway and DNS
- No Privacy Extensions, ensuring stable addresses derived from MAC addresses
- Proper firewall configuration for essential ICMPv6 traffic

## Debugging Network Issues

1. Check systemd-networkd status:
   ```
   systemctl status systemd-networkd
   ```

2. View network interfaces and their status:
   ```
   networkctl status
   ```

3. View detailed interface status:
   ```
   networkctl status <interface-name>
   ```

4. Check logs for network issues:
   ```
   journalctl -u systemd-networkd
   ```

5. For more verbose logging, enable debug:
   ```
   # Add to your configuration:
   systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
   ```

## Network Security

The firewall is configured to:
- Allow SSH access (port 22)
- Allow essential ICMP and ICMPv6 traffic
- Treat the primary interface and loopback as trusted
- Block all other incoming connections
- Rate-limit SSH connections to prevent brute force attacks

## Future Improvements

1. Consider implementing networkd-dispatcher for network event handling
2. Add support for VLANs if needed
3. Implement more comprehensive network monitoring
