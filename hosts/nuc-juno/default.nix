# hosts/nuc-juno/default.nix
#
# Main configuration for nuc-juno homelab server
{ configLib, pkgs, ... }:

{
  imports = [
    # Hardware configuration
    ./hardware

    # Base server profile with integrated security
    (configLib.profileImport "server/homelab.nix")

    # Host-specific service imports
    (configLib.moduleImport "services/minio.nix")
    # Download services
    (configLib.moduleImport "services/prowlarr.nix")
    (configLib.moduleImport "services/sonarr.nix")
    (configLib.moduleImport "services/radarr.nix")
    (configLib.moduleImport "services/sabnzbd.nix")
    (configLib.moduleImport "services/recyclarr.nix")
    # Monitoring
    (configLib.moduleImport "services/node-exporter.nix")

    # Host-specific service configurations
    ./config-minio.nix
  ];

  # Setup for agenix encryption - will be replaced after initial deployment
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH6M78kbtrK7o7l6gAqoRBUa+iAzIfdU/ob9YvW8fhA7";

  # Custom system packages
  environment.systemPackages = with pkgs; [
    smartmontools
    lm_sensors
    nvme-cli
    sysstat
    iotop
  ];

  # System version (currently matches homelab.nix)
  system.stateVersion = "24.11";
}
