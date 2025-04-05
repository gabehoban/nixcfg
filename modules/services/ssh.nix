# modules/services/ssh.nix
#
# SSH server and client configuration with security hardening
{ pkgs, ... }:
{
  #
  # OpenSSH server configuration
  #
  services.openssh = {
    enable = true;

    # Security settings
    settings = {
      # Prevent direct root login for security except on local subnet
      PermitRootLogin = "no";
      # Allow only key-based authentication
      PasswordAuthentication = false;
    };

    # Allow root login from trusted subnet
    extraConfig = ''
      Match Address 10.32.0.0/16
        PermitRootLogin yes
    '';

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
    startAgent = false;
    agentPKCS11Whitelist = "${pkgs.opensc}/lib/opensc-pkcs11.so";
    extraConfig = ''
      PKCS11Provider "${pkgs.opensc}/lib/opensc-pkcs11.so"
    '';
  };
}
