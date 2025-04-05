# hosts/sekio/security.nix
#
# Security configuration for sekio host with comprehensive hardening
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  # Security settings for Raspberry Pi are now directly applied through the flattened hw-platform-rpi.nix module

  # ──────────────────── SSH Hardening ────────────────────
  
  # SSH security enhancements with modern cryptography and restrictions
  services.openssh = {
    settings = {
      # Restrict forwarding for enhanced security
      AllowTcpForwarding = mkForce false;
      AllowAgentForwarding = mkForce false;
      AllowStreamLocalForwarding = mkForce false;
      GatewayPorts = mkForce "no";
      PermitTunnel = mkForce "no";
      
      # Limit authentication methods and attempts
      MaxAuthTries = lib.mkForce 3; # Override platform default (12)
      MaxSessions = 3;
      LoginGraceTime = lib.mkForce 30; # Override the platform default (20)
      MaxStartups = "3:50:10";
      
      # Disable obsolete and insecure functionality
      X11Forwarding = false;
      TCPKeepAlive = false;
      PermitUserEnvironment = false;
      PermitEmptyPasswords = false;
      Compression = false;
      
      # Enhanced logging
      LogLevel = "VERBOSE";
      
      # Session security settings
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
    };
    
    # Enforce SSH key authentication only
    settings.PasswordAuthentication = mkForce false;
    settings.KbdInteractiveAuthentication = mkForce false;
    settings.ChallengeResponseAuthentication = mkForce false;
  };

  # ──────────────────── Firewall Configuration ────────────────────
  
  # Firewall configuration specific to sekio using the NFT-based firewall
  modules.network.firewall = {
    enable = true;
    openTcpPorts = [
      # SSH is enabled by default, no need to add 22
    ];
    openUdpPorts = [
      123 # NTP
      5353 # mDNS for .local hostname resolution
    ];
    # Allow ping but rate limit it
    allowPing = true;
    # Log all denied packets for diagnostics
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
        extraLines = [
          "ct state invalid counter drop"
        ];
      };
    };
  };

  # ──────────────────── Kernel/System Hardening ────────────────────
  
  # Comprehensive kernel hardening parameters
  boot.kernelParams = [
    # CPU vulnerability mitigations
    "mitigations=auto"           # Enable security mitigations with performance considerations
    "spectre_v2=on"              # Enable Spectre variant 2 mitigations
    "spec_store_bypass_disable=on" # Protect against Spectre variant 4
    "pti=on"                     # Kernel page table isolation (Meltdown protection)
    
    # Security features
    "apparmor=1"                 # Enable AppArmor
    "security=apparmor"          # Use AppArmor LSM
    "lockdown=confidentiality"   # Prevent modification of kernel code
    "slab_nomerge=1"             # Prevent slab merging (reduces heap manipulation attacks)
    "slub_debug=FZ"              # Enable sanity check and redzone protection
    "init_on_alloc=1"            # Initialize memory on allocation
    "init_on_free=1"             # Initialize memory on free
    "page_alloc.shuffle=1"       # Reduce memory disclosure attacks
    
    # Hardware security features
    "randomize_kstack_offset=on" # Randomize kernel stack offset
    "vsyscall=none"              # Disable vsyscall table
    "debugfs=off"                # Disable debugfs
    
    # Network hardening
    "tcp_timestamps=0"           # Disable TCP timestamps to prevent fingerprinting
  ];
  
  # System-wide security settings
  security = {
    # Enable AppArmor for mandatory access control
    apparmor = {
      enable = true;
      packages = [ pkgs.apparmor-profiles ];
    };
    
    # Enable kernel module signing
    protectKernelImage = true;
    
    # Restrict access to kernel modules and parameters
    lockKernelModules = true;
    
    # Enhance kernel memory protection
    allowSimultaneousMultithreading = false;
    
    # Auditing with simplified configuration
    auditd.enable = true;
    # Custom audit rules will be added in the future when needed
  };
  
  # Kernel hardening through sysctl
  boot.kernel.sysctl = {
    # Restrict kernel pointer exposure
    "kernel.kptr_restrict" = 2;
    
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
    
    # Restrict process creation
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.yama.ptrace_scope" = 2;
    
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
  
  # ──────────────────── Hardened Resource Limits ────────────────────
  
  # Set resource limits to prevent fork bombs and other DoS attacks
  security.pam.loginLimits = [
    # Default limits for all users
    { domain = "*"; item = "nproc"; type = "soft"; value = "1024"; }
    { domain = "*"; item = "nproc"; type = "hard"; value = "2048"; }
    { domain = "*"; item = "nofile"; type = "soft"; value = "1024"; }
    { domain = "*"; item = "nofile"; type = "hard"; value = "4096"; }
    { domain = "*"; item = "core"; type = "soft"; value = "0"; } # Disable core dumps
    
    # More permissive limits for system services
    { domain = "root"; item = "nproc"; type = "soft"; value = "unlimited"; }
    { domain = "root"; item = "nofile"; type = "soft"; value = "65536"; }
  ];
  
  # ──────────────────── Security Packages ────────────────────
  
  # Install security-related packages
  environment.systemPackages = with pkgs; [
    aide            # Advanced intrusion detection environment
    chkrootkit      # Rootkit detection
    lynis           # System auditing tool
    nmap            # Network scanner for security audits
  ];
}
