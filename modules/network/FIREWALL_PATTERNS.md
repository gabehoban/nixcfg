# Firewall Configuration Patterns

This document describes standard patterns for configuring the NFT-based firewall in this NixOS configuration.

## Host Configuration Examples

### Workstation Host
```nix
# Minimal configuration in hosts/workstation/default.nix
modules.network.firewall = {
  enable = true;
};
```

### Sekio Host (Raspberry Pi NTP Server)
```nix
# Basic configuration in hosts/sekio/default.nix
modules.network.firewall = {
  enable = true;
};

# Detailed configuration in hosts/sekio/security.nix
modules.network.firewall = {
  enable = true;
  openTcpPorts = [
    # SSH is enabled by default, no need to add 22
  ];
  openUdpPorts = [
    123 # NTP
    5353 # mDNS for .local hostname resolution
  ];
  allowPing = true;
  logRefusedConnections = true;
  
  # Add custom rules to protect against common attacks
  rules = {
    # Basic anti-scan measures
    rate-limit-ssh = {
      from = "all";
      to = [ "fw" ];
      extraLines = [
        # Limit new SSH connections to 3 per minute from the same source
        "tcp dport 22 ct state new limit rate 3/minute counter accept"
      ];
    };
    
    # Drop invalid packets
    drop-invalid = {
      from = "all";
      to = "all";
      ruleType = "ban";
      extraLines = [
        "ct state invalid counter drop"
      ];
    };
  };
};
```

## Basic Concepts

The firewall implementation uses a zone-based approach where:

1. **Zones** define network segments (interfaces, IP ranges, etc.)
2. **Rules** control traffic between zones
3. **Verdicts** determine what happens to matching traffic (accept, drop, reject)

## Common Zone Patterns

### Host Zones

The `fw` zone (short for "firewall") always represents the local host running the firewall. This is a special built-in zone.

### Network Interface Zones

```nix
zones = {
  trusted = {
    interfaces = [ "eth0" ];
  };
  
  guest = {
    interfaces = [ "wlan0" ];
  };
};
```

### IP Subnet Zones

```nix
zones = {
  home = {
    ipv4Addresses = [ "192.168.1.0/24" ];
  };
  
  vpn = {
    ipv4Addresses = [ "10.10.0.0/24" ];
  };
};
```

### Nested/Hierarchical Zones

```nix
zones = {
  uplink = {
    interfaces = [ "eth0" "eth1" ];
  };
  
  servers = {
    parent = "uplink";  # This is a subzone of 'uplink'
    ipv4Addresses = [ "192.168.10.0/24" ];
  };
};
```

## Common Rule Patterns

### Allow Incoming Service

```nix
rules = {
  ssh = {
    from = "all";         # From any zone
    to = [ "fw" ];        # To this firewall
    allowedTCPPorts = [ 22 ];
  };
};
```

### Allow Specific Source Only

```nix
rules = {
  admin-ssh = {
    from = [ "trusted" ];  # Only from trusted zone
    to = [ "fw" ];         # To this firewall
    allowedTCPPorts = [ 22 ];
  };
};
```

### Forward Traffic Between Zones

```nix
rules = {
  trusted-to-guest = {
    from = [ "trusted" ]; # From trusted zone
    to = [ "guest" ];     # To guest zone
    verdict = "accept";   # Accept all traffic
  };
};
```

### Rate Limiting

```nix
rules = {
  limit-ssh = {
    from = "all";
    to = [ "fw" ];
    extraLines = [
      # Limit new SSH connections to 3 per minute
      "tcp dport 22 ct state new limit rate 3/minute counter accept"
    ];
  };
};
```

### Blocking Traffic

```nix
rules = {
  block-bad-ips = {
    from = [ "blacklist" ];  # A zone containing bad IPs
    to = "all";
    ruleType = "ban";        # Apply early, before regular rules
    extraLines = [
      "counter drop"
    ];
  };
};
```

## Best Practices

### 1. Zone Organization

- Group related interfaces/subnets into logical zones
- Use descriptive zone names
- Create hierarchical zones for fine-grained control

### 2. Rule Structure

- Use descriptive rule names
- Start with most specific rules
- Use `ruleType` to control rule application order:
  - `ban`: Applied first (blocks traffic)
  - `rule`: Applied for most normal rules (allows traffic)
  - `policy`: Applied last (default actions)

### 3. Egress Filtering

Control outgoing traffic for enhanced security:

```nix
rules = {
  allow-web-only = {
    from = [ "fw" ];        # From this firewall
    to = [ "internet" ];    # To internet zone
    allowedTCPPorts = [ 80 443 ];  # Allow only HTTP/HTTPS
  };
};
```

### 4. Logging

Add logging for diagnosing connection issues:

```nix
rules = {
  log-dropped = {
    from = "all";
    to = "all";
    ruleType = "policy";  # Apply last
    extraLines = [
      "counter log prefix \"dropped: \" drop"
    ];
  };
};
```

## Common Use Cases

### Web Server

```nix
# Allow HTTP/HTTPS from anywhere
rules.web = {
  from = "all";
  to = [ "fw" ];
  allowedTCPPorts = [ 80 443 ];
};
```

### SSH Server with Restrictions

```nix
# Allow SSH only from trusted networks
rules.ssh = {
  from = [ "trusted" ];
  to = [ "fw" ];
  allowedTCPPorts = [ 22 ];
};
```

### Internal DNS Server

```nix
# Allow DNS queries from internal networks
rules.dns = {
  from = [ "internal" ];
  to = [ "fw" ];
  allowedTCPPorts = [ 53 ];
  allowedUDPPorts = [ 53 ];
};
```

### NAT Gateway

```nix
# Allow forwarding from internal to internet
rules.nat-forward = {
  from = [ "internal" ];
  to = [ "internet" ];
  verdict = "accept";
};

# Enable masquerading for outgoing connections
rules.masquerade = {
  from = [ "internal" ];
  to = [ "internet" ];
  masquerade = true;
};
```

## Testing and Debugging

1. Inspect active nftables rules:
   ```
   sudo nft list ruleset
   ```

2. Test connections from different zones:
   ```
   curl -v http://server-in-zone
   ```

3. View logs for dropped connections:
   ```
   journalctl -f | grep dropped
   ```

4. Temporarily allow all traffic for testing:
   ```nix
   rules.emergency-all = {
     from = "all";
     to = "all";
     verdict = "accept";
   };
   ```

## Converting from iptables Rules

| iptables Command | NFT-based Firewall Equivalent |
|------------------|-------------------------------|
| `-A INPUT -p tcp --dport 22 -j ACCEPT` | `rules.ssh = { from = "all"; to = ["fw"]; allowedTCPPorts = [ 22 ]; }` |
| `-A FORWARD -i eth0 -o eth1 -j ACCEPT` | `rules.forward = { from = ["eth0zone"]; to = ["eth1zone"]; verdict = "accept"; }` |
| `-t nat -A POSTROUTING -o eth0 -j MASQUERADE` | `rules.masq = { from = ["internal"]; to = ["internet"]; masquerade = true; }` |