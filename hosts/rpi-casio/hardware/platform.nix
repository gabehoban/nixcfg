# hosts/rpi-casio/hardware/platform.nix
#
# Raspberry Pi hardware optimizations for NTP server functionality
# Disables unused wireless interfaces and configures UART for GPS
_:

{
  # Disable onboard wireless interfaces to:
  # 1. Reduce power consumption
  # 2. Eliminate potential RF interference with GPS receiver
  # 3. Free up resources for NTP processing
  boot.extraModprobeConfig = ''
    # Disable onboard WiFi - not needed for NTP server
    blacklist brcmfmac
    blacklist brcmutil

    # Disable onboard Bluetooth - not needed and UART conflict
    blacklist btbcm
    blacklist hci_uart
  '';

  # Prevent automatic login which would create getty on serial ports
  services.getty.autologinUser = null;

  # Disable all serial consoles to ensure GPS has exclusive access to UART
  # This is critical as the GPS module requires dedicated access to
  # the primary UART (ttyAMA0) for reliable timing signals
  systemd.services."serial-getty@ttyAMA0".enable = false; # Primary UART
  systemd.services."serial-getty@ttyS0".enable = false; # Alias for ttyAMA0
  systemd.services."serial-getty@serial0".enable = false; # Physical port mapping
  systemd.services."serial-getty@serial1".enable = false; # Secondary UART

  # Enable I2C bus for DS3231 Real-Time Clock backup
  # The RTC provides timing resilience during GPS signal loss
  hardware.i2c.enable = true;
}
