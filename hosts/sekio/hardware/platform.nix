# hosts/sekio/hardware/platform.nix
#
# Raspberry Pi platform-specific settings for Sekio
{ ... }:

{
  # Configure additional GPIO/WiFi settings
  boot.extraModprobeConfig = ''
    # Disable onboard WiFi
    blacklist brcmfmac
    blacklist brcmutil

    # Disable onboard Bluetooth
    blacklist btbcm
    blacklist hci_uart
  '';

  # Explicitly disable serial console on UART0 (ttyAMA0/ttyS0)
  # This is critical to free up the UART for GPS
  services.getty.autologinUser = null;

  # Disable ALL serial consoles to ensure the GPS has exclusive access
  systemd.services."serial-getty@ttyAMA0".enable = false;
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@serial0".enable = false;
  systemd.services."serial-getty@serial1".enable = false;

  # Add explicit udev rules to prevent console allocation on UART
  services.udev.extraRules = ''
    # Prevent any console allocation on UART devices
    KERNEL=="ttyAMA0", OPTIONS+="noauto", ENV{SYSTEMD_WANTS}=""
    KERNEL=="ttyS0", OPTIONS+="noauto", ENV{SYSTEMD_WANTS}=""
    KERNEL=="serial0", OPTIONS+="noauto", ENV{SYSTEMD_WANTS}=""
    KERNEL=="serial1", OPTIONS+="noauto", ENV{SYSTEMD_WANTS}=""
  '';

  # Enable I2C for RTC and other peripherals
  hardware.i2c.enable = true;
}
