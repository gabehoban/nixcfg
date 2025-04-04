# hosts/sekio/security.nix
#
# Security configuration for sekio host
{
  config,
  lib,
  trustedNetworks,
  ...
}:

{
  # Security settings for Raspberry Pi
  hardware.raspberry-pi.security = {
    enableFirewall = true;
    enableSSHHardening = true;
    enableFail2ban = true;
  };

  # SSH security enhancements specific to this host
  # These settings extend the basic settings from hardware.raspberry-pi.security.enableSSHHardening
  services.openssh = {
    settings = {
      # Limit forwarding for this host - additional security
      AllowTcpForwarding = lib.mkDefault false;
      AllowAgentForwarding = lib.mkDefault false;

      # Use more secure ciphers and key exchange
      Ciphers = lib.mkDefault [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
      ];

      KexAlgorithms = lib.mkDefault [
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group-exchange-sha256"
      ];
    };
  };

  # Firewall configuration specific to sekio
  networking.firewall = {
    enable = lib.mkForce true; # Override the default setting from network/basic.nix
    allowedTCPPorts = [
      22 # SSH
    ];
    allowedUDPPorts = [
      123 # NTP
      5353 # mDNS for .local hostname resolution
    ];
    # Restrict ping
    allowPing = true;
    # Log all denied packets for diagnostics
    logRefusedConnections = true;
    logRefusedPackets = true;
  };

  # Add fail2ban for SSH protection - only applied if not enabled by the platform module
  services.fail2ban = lib.mkIf (!config.hardware.raspberry-pi.security.enableFail2ban) {
    enable = true;
    # Define trusted networks
    ignoreIP = [
      trustedNetworks.loopback
      trustedNetworks.homeNetwork
    ];
    # Configure the jail
    jails.sshd.settings = {
      enabled = true;
      maxretry = 5;
      findtime = 600;
      bantime = 600;
      ignoreip = "${trustedNetworks.loopback} ${trustedNetworks.homeNetwork}";
    };
  };

  # Raspberry Pi specific hardening kernel parameters
  boot.kernelParams = [
    # Only enable mitigation if compatible with Raspberry Pi
    "mitigations=auto"
  ];

  # Enhanced kernel protection
  security.protectKernelImage = true;
}