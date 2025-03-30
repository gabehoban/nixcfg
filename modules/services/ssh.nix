# modules/services/ssh.nix
#
# SSH server and client configuration with security hardening
_: {
  #
  # OpenSSH server configuration
  #
  services.openssh = {
    enable = true;

    # Security settings
    settings = {
      PermitRootLogin = "no"; # Prevent direct root login for security
      PasswordAuthentication = false; # Allow only key-based authentication
    };

    # Additional security settings to consider:
    # X11Forwarding = false;              # Disable X11 forwarding if not needed
    # AllowTcpForwarding = false;         # Disable TCP forwarding if not needed
    # MaxAuthTries = 3;                   # Limit authentication attempts
    # LoginGraceTime = 30;                # Limit login time window
  };

  #
  # SSH client configuration
  #
  programs.ssh = {
    startAgent = true; # Automatically start SSH agent for key management
  };
}