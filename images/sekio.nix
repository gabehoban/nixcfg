# images/sekio.nix
#
# SD card image for sekio NTP server
{
  ...
}:
{
  imports = [
    # Import the base Raspberry Pi image
    ./raspberry-pi-base.nix
  ];

  # Basic system settings
  networking.hostName = "sekio";
  sdImage.imageBaseName = "nixos-sd-image-sekio";
}