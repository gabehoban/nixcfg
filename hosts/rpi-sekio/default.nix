# hosts/rpi-sekio/default.nix
#
# Stratum 1 NTP server using GPS for timing (Raspberry Pi 4)
{
  configLib,
  ...
}:
{
  networking = {
    hostName = "rpi-sekio";
    hostId = "a7b92c14";
  };

  # ───────────────────────────────────────────
  # Module Imports
  # ───────────────────────────────────────────
  imports = [
    # Common GPS/NTP server profile
    (configLib.profileImport "server/gps-ntp.nix")

    # Host-specific hardware configuration
    ./hardware

    # Host-specific configurations
    ./optimization.nix
  ];

  # ───────────────────────────────────────────
  # Security Settings
  # ───────────────────────────────────────────
  # SSH host key for age encryption
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJco2ctNIBP1fph74SCE6LMv8oKF1PYjRupAmbC6pdd3";
}
