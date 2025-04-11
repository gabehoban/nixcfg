# modules/core/security.nix
#
# Common security hardening configuration for all NixOS systems
{
  config,
  lib,
  ...
}:

with lib;

let
  # Default secure kernel parameters for all systems
  commonKernelParams = [
    "lockdown=none"
    "init_on_alloc=1" # Initialize heap memory allocations
    "init_on_free=1" # Initialize freed heap memory
    "page_alloc.shuffle=1" # Randomize page allocator freelists
    "pti=on" # Page Table Isolation (Meltdown mitigation)
    "randomize_kstack_offset=on" # Strengthen kernel stack ASLR
    "vsyscall=none" # Disable vsyscall table (legacy feature)
  ];

  # Common sysctl hardening parameters
  commonSysctlParams = {
    # Restrict access to kernel logs
    "kernel.dmesg_restrict" = 1;

    # Restrict SysRq keys
    "kernel.sysrq" = 0;

    # Restrict user space access to kernel memory
    "vm.mmap_min_addr" = 65536;

    # Randomize address space layout
    "kernel.randomize_va_space" = 2;

    # Restrict core dumps
    "fs.suid_dumpable" = 0;
    "kernel.core_pattern" = "|/bin/false";

    # Network security
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_rfc1337" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

    # Restrict unprivileged user namespaces
    "kernel.unprivileged_userns_clone" = 0;
  };

  # Default login limits to prevent resource exhaustion attacks
  defaultLoginLimits = [
    # Default limits for all users
    {
      domain = "*";
      item = "nproc";
      type = "soft";
      value = "1024";
    }
    {
      domain = "*";
      item = "nproc";
      type = "hard";
      value = "2048";
    }
    {
      domain = "*";
      item = "nofile";
      type = "soft";
      value = "1024";
    }
    {
      domain = "*";
      item = "nofile";
      type = "hard";
      value = "4096";
    }
    {
      domain = "*";
      item = "core";
      type = "soft";
      value = "0";
    } # Disable core dumps

    # More permissive limits for system services
    {
      domain = "root";
      item = "nproc";
      type = "soft";
      value = "unlimited";
    }
    {
      domain = "root";
      item = "nofile";
      type = "soft";
      value = "65536";
    }
  ];

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

  # Firewall anti-scan rules

in
{
  # Apply kernel hardening parameters
  boot.kernelParams = commonKernelParams;

  # Apply sysctl hardening
  boot.kernel.sysctl = commonSysctlParams;

  # Resource limits hardening
  security.pam.loginLimits = defaultLoginLimits;

  # SSH hardening settings
  services.openssh = {
    settings = sshSettings;

    # Use keyfiles from persistence if impermanence is enabled
    hostKeys = mkIf config.impermanence.enable persistentHostKeys;
  };

  # Basic firewall configuration
  networking.firewall = {
    enable = true;
    allowPing = true;

    # Rate limit SSH connections
    extraCommands = ''
      # Limit new SSH connections to 3 per minute from the same source
      iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
      iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
    '';
  };
}
