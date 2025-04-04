{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Direct config.txt settings for the Raspberry Pi
  # These are applied directly to the firmware config.txt file
  hardware.raspberry-pi = {
    # Apply overlays handled in default.nix to avoid duplicates
    
    # Additional firmware settings via the config attribute
    # See: https://github.com/NixOS/nixos-hardware/blob/master/raspberry-pi/4/config.nix
    config = {
      # Set UART baud rate for GPS
      "init_uart_baud" = "115200";
      
      # Disable audio (dtparam=audio=off)
      "dtparam" = {
        "audio" = "off";
      };
    };
    
    # Set overlay parameters to enable more specific settings
    overlays = {
      # i2c-rtc overlay with parameters
      i2c-rtc = {
        devices = [
          {
            # RV3028 RTC with wakeup support and backup mode
            name = "rv3028";
            address = "0x52";
            params = [
              "wakeup-source"
              "backup-switchover-mode=3"
            ];
          }
        ];
      };
      
      # PPS GPIO overlay with pin parameter
      pps-gpio = {
        params = [
          "gpiopin=18"
        ];
      };
    };
  };
}