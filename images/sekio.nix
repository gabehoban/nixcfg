{
  configLib,
  pkgs,
  lib,
  modulesPath,
  inputs,
  ...
}:
{
  imports = [
    # Base image
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    # Sekio host configuration
    (configLib.relativeToRoot "hosts/sekio")
  ];

  # Set system configuration for the image
  sdImage = {
    # Add optional extra space to the rootfs (in MiB)
    rootFsSize = 4096;
    # Set image compression, options: [none, gzip, bzip2, xz]
    compressImage = "bzip2";
    # Set a descriptive image name
    imageName = "nixos-sd-image-sekio-${lib.trivial.release}.img";
  };

  # Enable SSH for remote access (initial setup only)
  services.openssh = {
    enable = true;
    settings = {
      # Allow root login for initial setup only
      PermitRootLogin = "yes";
      # Allow password authentication for initial setup only
      PasswordAuthentication = true;
    };
  };

  # Set secure initial password for setup
  # This will be replaced after nixos-rebuild with the host configuration
  users.users.root.initialPassword = "Sekio-R00t-Init-2024";

  # Configure network for headless access
  networking = {
    wireless.enable = false;
    networkmanager.enable = true;
    
    # Set hostname for easier discovery on the network
    hostName = "sekio";
    
    # Enable mDNS so the device can be found at sekio.local
    # This is compatible with Avahi/Bonjour
    firewall.allowedUDPPorts = [ 5353 ];
  };
  
  # Enable mDNS service for hostname.local discovery
  services.avahi = {
    enable = true;
    nssmdns = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
  };

  # Add some basic utilities for initial setup
  environment.systemPackages = with pkgs; [
    vim
    htop
    wget
    git
    usbutils
    pciutils
  ];

  # Name for the image in metadata
  system.stateVersion = "23.11";
}