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
    # Absolutely minimal config for SD image builder
    (configLib.relativeToRoot "hosts/sekio/hardware")
    (configLib.moduleImport "core/locale.nix")
    (configLib.moduleImport "services/ssh.nix")
  ];
  
  # Basic system settings
  networking.hostName = "sekio";
  
  # No home-manager in minimal image

  # Set system configuration for the image
  sdImage.imageBaseName = "nixos-sd-image-sekio";
  sdImage.compressImage = true;
  
  # Increase the size of the root filesystem (4 GB)
  fileSystems."/".autoResize = true;

  # Enable SSH for remote access (initial setup only)
  services.openssh = {
    enable = true;
    settings = {
      # Allow root login for initial setup only
      PermitRootLogin = lib.mkForce "yes";
      # Allow password authentication for initial setup only
      PasswordAuthentication = lib.mkForce true;
    };
  };

  # Set secure initial password for setup
  # This will be replaced after nixos-rebuild with the host configuration
  users.users.root.initialPassword = "Sekio-R00t-Init-2024";

  # Configure network for headless access
  networking = {
    wireless.enable = false;
    networkmanager.enable = true;
    
    # Enable mDNS so the device can be found at sekio.local
    # This is compatible with Avahi/Bonjour
    firewall.allowedUDPPorts = [ 5353 ];
  };
  
  # Enable mDNS service for hostname.local discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
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
  
  # Disable ZFS for Raspberry Pi
  boot.supportedFilesystems = lib.mkForce [ "vfat" "ext4" ];
  
  # Use minimal kernel parameters for the image - full config will be used after install
  # We're using mkForce to ensure these override any others during image build
  boot.kernelParams = lib.mkForce [
    "console=tty0"
  ];
}