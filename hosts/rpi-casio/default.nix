# hosts/rpi-casio/default.nix
#
# Stratum 1 NTP server using GPS for timing (Raspberry Pi 4)
{
  configLib,
  ...
}:
{
  networking = {
    hostName = "rpi-casio";
    hostId = "9e07b0bc";
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
    ./security.nix
    ./optimization.nix
  ];

  # ───────────────────────────────────────────
  # Security Settings
  # ───────────────────────────────────────────
  # SSH host key for age encryption
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHXKcmTzg1RhXaO15q5bk4zoQR8B5i/XzQTkoJ/tX8Q9";
}
