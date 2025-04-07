# hosts/nuc-juno/security.nix
#
# Security configuration for nuc-juno
_:

{
  # Enable the firewall with module-specific ports handled in respective modules
  modules.network.firewall.enable = true;

  # SSH hardening
  services.openssh = {
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };

    # Use keyfile for better security
    hostKeys = [
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
  };

  # Secure kernel parameters
  boot.kernelParams = [
    "init_on_alloc=1" # Initialize heap memory allocations
    "init_on_free=1" # Initialize freed heap memory
    "page_alloc.shuffle=1" # Randomize page allocator freelists
    "pti=on" # Page Table Isolation (Meltdown mitigation)
    "randomize_kstack_offset=on" # Strengthen kernel stack ASLR
    "vsyscall=none" # Disable vsyscall table (legacy feature)
    "lockdown=confidentiality" # Enable kernel lockdown
  ];
}
