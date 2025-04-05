# images/casio.nix
#
# SD card image for casio NTP server
{
  ...
}:
{
  imports = [
    # Import the base Raspberry Pi image
    ./raspberry-pi-base.nix
  ];

  # Basic system settings
  networking.hostName = "casio";
  sdImage.imageBaseName = "nixos-sd-image-casio";
}