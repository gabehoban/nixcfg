# hosts/nuc-luna/default.nix
#
# Main configuration for nuc-luna homelab server
{ configLib, pkgs, ... }:

{
  imports = [
    # Hardware configuration
    ./hardware

    # Base server profile
    (configLib.profileImport "server/homelab.nix")

    # Host-specific service imports
    (configLib.moduleImport "services/storage-minio.nix")
    (configLib.moduleImport "services/media-plex.nix")
    # Monitoring
    (configLib.moduleImport "services/mon-node-exporter.nix")

    # Host-specific service configurations
    ./config-minio.nix
  ];

  # Setup for agenix encryption - will be replaced after initial deployment
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRk+xXXDPapiVY6Sj1p3JkO3HTkR+vaiwGtRjSw7695";

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
