# images/rpi-sekio.nix
#
# SD card image for rpi-sekio NTP server
{
  ...
}:
{
  imports = [
    # Import the base Raspberry Pi image
    ./raspberry-pi-base.nix
  ];

  # Basic system settings
  networking.hostName = "rpi-sekio";
  sdImage.imageBaseName = "nixos-sd-image-rpi-sekio";
}