# hosts/nuc-titan/default.nix
#
# Main configuration for nuc-titan build host
{ configLib, pkgs, ... }:

{
  imports = [
    # Hardware configuration
    ./hardware

    # Base profiles
    (configLib.profileImport "server/homelab.nix")
    (configLib.profileImport "server/build-host.nix")

    # Service modules
    (configLib.moduleImport "services/bind.nix")
    (configLib.moduleImport "services/attic.nix")
    (configLib.moduleImport "services/cloudflared.nix")
    (configLib.moduleImport "services/github-runner.nix")
  ];

  # Allow the cloudflared package which is currently marked as broken
  nixpkgs.config.allowBroken = true;

  # Setup for agenix encryption - will be replaced after initial deployment
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPqAr7BQAsfk4IkUuSEsoTLYERRjnKyulKeBtoYMluKG";

  # Custom system packages for build host
  environment.systemPackages = with pkgs; [
    # Development tools
    gcc
    clang
    gnumake
    cmake
    ninja
    binutils

    # Build utilities
    ccache
    linuxPackages.perf
    git-lfs
    nix-output-monitor
    nix-tree

    # System monitoring
    htop
    iotop
    lm_sensors
    nvme-cli
    sysstat
  ];

  # System version (currently matches homelab.nix)
  system.stateVersion = "24.11";
}
