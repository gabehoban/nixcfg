# Network Modules

This directory contains all networking-related modules.

## Contents

- `basic.nix`: Basic network configuration with NetworkManager settings
- `dns.nix`: DNS configuration and resolvers
- `firewall.nix`: NFT-based firewall using [nixos-nftables-firewall](https://github.com/thelegy/nixos-nftables-firewall)

## Firewall Usage

The NFT-based firewall module provides a simpler interface to the powerful [nixos-nftables-firewall](https://github.com/thelegy/nixos-nftables-firewall) module. Here's how to use it:

### Basic Usage

```nix
{ ... }:
{
  modules.network.firewall = {
    enable = true;
    openTcpPorts = [ 80 443 ];
    openUdpPorts = [ 51820 ]; # For WireGuard
  };
}
```

> Note: SSH (port 22) is enabled by default for all connections

### Advanced Zone-Based Configuration

The firewall supports network zones for more granular control:

```nix
{ ... }:
{
  modules.network.firewall = {
    enable = true;
    
    # Define network zones
    zones = {
      trusted = {
        interfaces = [ "eth0" ];
        ipv4Addresses = [ "192.168.1.0/24" ];
      };
      vpn = {
        interfaces = [ "wg0" ];
      };
    };
    
    # Define custom rules
    rules = {
      # Override default SSH rule to restrict access to trusted network
      ssh = {
        from = [ "trusted" ];
        to = [ "fw" ];
        allowedTCPPorts = [ 22 ];
      };
      
      # Allow HTTP/HTTPS from anywhere
      web = {
        from = "all";
        to = [ "fw" ];
        allowedTCPPorts = [ 80 443 ];
      };
      
      # Forward all traffic from VPN to the internet
      vpn-forward = {
        from = [ "vpn" ];
        to = "all";
        verdict = "accept";
      };
    };
  };
}
```

### Options

- `enable` - Enable the NFT-based firewall
- `openPorts` - List of TCP/UDP ports to open
- `openTcpPorts` - List of TCP ports to open
- `openUdpPorts` - List of UDP ports to open
- `allowPing` - Whether to allow ICMP echo requests (default: true)
- `logRefusedConnections` - Whether to log refused connections (default: false)
- `zones` - Network zones definition
- `rules` - Custom firewall rules

For more advanced configuration options, consult the [nixos-nftables-firewall documentation](https://thelegy.github.io/nixos-nftables-firewall/).
