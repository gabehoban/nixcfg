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
      # Prevent direct root login for security
      PermitRootLogin = "no";
      # Allow only key-based authentication
      PasswordAuthentication = false;
    };

    # Additional security settings to consider:
    # # Disable X11 forwarding if not needed
    # X11Forwarding = false;
    # # Disable TCP forwarding if not needed
    # AllowTcpForwarding = false;
    # # Limit authentication attempts
    # MaxAuthTries = 3;
    # # Limit login time window
    # LoginGraceTime = 30;
  };

  #
  # SSH client configuration
  #
  programs.ssh = {
    # Automatically start SSH agent for key management
    startAgent = true;
  };
}
