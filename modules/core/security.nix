# modules/core/security.nix
#
# Common security hardening configuration for all NixOS systems
{
  config,
  lib,
  ...
}:

let
  # SSH hardening common settings
  sshSettings = {
    # Basic settings
    PasswordAuthentication = false;
    PermitRootLogin = "no";
    X11Forwarding = false;

    # Enhanced security settings
    AllowTcpForwarding = false;
    AllowAgentForwarding = false;
    AllowStreamLocalForwarding = false;
    GatewayPorts = "no";
    PermitTunnel = "no";

    # Limit authentication methods and attempts
    MaxAuthTries = 3;
    MaxSessions = 3;
    LoginGraceTime = 30;
    MaxStartups = "3:50:10";

    # Disable obsolete and insecure functionality
    TCPKeepAlive = false;
    PermitUserEnvironment = false;
    PermitEmptyPasswords = false;
    Compression = false;

    # Enhanced logging
    LogLevel = "VERBOSE";

    # Session security settings
    ClientAliveInterval = 300;
    ClientAliveCountMax = 2;

    # Enforce SSH key authentication only
    KbdInteractiveAuthentication = false;
    ChallengeResponseAuthentication = false;
  };

  # SSH host keys for systems using persistence
  persistentHostKeys = [
    {
      path = "/persist/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
    {
      path = "/persist/etc/ssh/ssh_host_rsa_key";
      type = "rsa";
      bits = 4096;
    }
  ];
in
{
  # SSH hardening settings
  services.openssh = {
    settings = sshSettings;

    # Use keyfiles from persistence if impermanence is enabled
    hostKeys = lib.mkIf config.impermanence.enable persistentHostKeys;
  };

  # Basic firewall configuration
  networking.firewall = {
    enable = true;
    allowPing = true;
  };
}
