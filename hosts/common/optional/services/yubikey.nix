# YubiKey hardware security key support configuration
{ pkgs, ... }:
{
  #
  # YubiKey management applications
  #
  environment.systemPackages = with pkgs; [
    yubioath-flutter # YubiKey OTP and OATH (TOTP/HOTP) authentication
    yubikey-manager-qt # YubiKey configuration tool
  ];

  #
  # Hardware support
  #

  # Enable GPG smartcard support for using YubiKey as a GPG key
  hardware.gpgSmartcards.enable = true;

  # Enable PC/SC daemon for smartcard communication
  services.pcscd.enable = true;

  # Add udev rules for YubiKey device detection
  services.udev.packages = with pkgs; [
    yubikey-personalization # Tools for personalizing YubiKeys
    libu2f-host # U2F host libraries and udev rules
  ];
}
