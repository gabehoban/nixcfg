# images/rpi-casio.nix
#
# SD card image for rpi-casio NTP server
{
  ...
}:
{
  imports = [
    # Import the base Raspberry Pi image
    ./raspberry-pi-base.nix
  ];

  # Basic system settings
  networking.hostName = "rpi-casio";
  sdImage.imageBaseName = "nixos-sd-image-rpi-casio";
}