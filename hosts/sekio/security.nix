# hosts/sekio/security.nix
#
# Security configuration for sekio host
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # SSH security enhancements specific to this host
  services.openssh = {
    settings = {
      # Disable root login completely
      PermitRootLogin = "no";
      
      # Disable password authentication, use keys only
      PasswordAuthentication = false;
      
      # Limit forwarding for this host
      AllowTcpForwarding = false;
      AllowAgentForwarding = false;
      
      # Additional security settings
      X11Forwarding = false;
      MaxAuthTries = 3;
      LoginGraceTime = 20;
      
      # Use more secure ciphers and key exchange
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
      ];
      
      KexAlgorithms = [
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group-exchange-sha256"
      ];
    };
  };
  
  # Firewall configuration specific to sekio
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22    # SSH
    ];
    allowedUDPPorts = [
      123   # NTP
      5353  # mDNS for .local hostname resolution
    ];
    # Restrict ping
    allowPing = true;
    # Log all denied packets for diagnostics
    logRefusedConnections = true;
    logRefusedPackets = true;
  };
  
  # Add fail2ban for SSH protection
  services.fail2ban = {
    enable = true;
    jails.sshd = ''
      enabled = true
      maxretry = 5
      findtime = 600
      bantime = 600
      ignoreip = 127.0.0.1/8 192.168.1.0/24 10.32.0.0/16
    '';
  };

  # Raspberry Pi specific hardening kernel parameters
  boot.kernelParams = [
    # Only enable mitigation if compatible with Raspberry Pi
    "mitigations=auto"
  ];
  
  # Enhanced kernel protection
  security.protectKernelImage = true;
  
  # USB power saving is now handled by raspberry-pi.enablePowerSaving
}