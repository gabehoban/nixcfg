# Network Configuration

This directory contains network-related configurations for the NixOS system.

## Files

- **network.nix** - Network configuration
  - NetworkManager settings
  - Firewall configuration
  - Avahi (mDNS) service discovery

## Usage

Include the network module in your configuration:

```nix
# Include all network modules
imports = [ ./network ];

# Or specifically import
imports = [ ./network/network.nix ];
```

## Adding New Network Services

When adding new network services or configurations:

1. For small additions, add them to `network.nix`
2. For larger features (like VPN, custom network services), create a new file
3. Import the new file in `default.nix`

Example for adding VPN configuration:

```nix
# ./network/vpn.nix
{ ... }: {
  services.openvpn.servers.myVPN = {
    # OpenVPN configuration
  };
}
```

```nix
# ./network/default.nix
{ ... }: {
  imports = [
    ./network.nix
    ./vpn.nix 
  ];
}
```
