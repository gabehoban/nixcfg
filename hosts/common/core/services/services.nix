# Core system services configuration
# Enables standard system maintenance and monitoring services
{ pkgs, ... }:
{
  services = {
    # SSD TRIM optimization
    # Periodically sends TRIM commands to SSDs to maintain performance
    fstrim.enable = true;

    # Power management service
    # Provides power management features (battery stats, suspend, etc.)
    upower.enable = true;

    # S.M.A.R.T monitoring for storage devices
    # Monitors disk health and reports potential failures
    smartd.enable = true;
  };

  # Required packages for enabled services
  environment.systemPackages = with pkgs; [
    smartmontools # Tools for smartd service
  ];
}
