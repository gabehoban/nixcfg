# modules/hardware/hw-gps.nix
#
# GPS hardware support with PPS timing for stratum 1 NTP servers
# Configures kernel modules, UART settings, and GPIO for precise timing signals
{ config, lib, pkgs, ... }:

{
  # UART configuration for GPS module communication
  boot = {
    # Set high baud rate for GPS module and redirect console away from UART
    kernelParams = [
      "init_uart_baud=115200" # Match GPS module's serial speed
      "console=tty0"          # Redirect console to HDMI/display instead of UART
    ];
    
    # Load kernel modules required for PPS timing
    kernelModules = [
      "pps_gpio" # Pulse-per-second signal via GPIO pins
      "pps_core" # Core PPS functionality for timing
    ];
  };

  # Free UART ports for GPS use - redundant with platform.nix but included
  # for completeness when this module is used independently
  systemd.services = {
    "serial-getty@ttyAMA0".enable = false;
    "serial-getty@ttyS0".enable = false;
    "serial-getty@serial0".enable = false;
    "serial-getty@serial1".enable = false;
  };

  # GPS daemon configuration - basic setup, more detailed in gpsd.nix
  services.gpsd = {
    enable = true;
    devices = [ "/dev/ttyAMA0" ]; # UART device for GPS NMEA data
    readonly = false;             # Allow configuration of the GPS device
  };

  # PPS timing on GPIO pin 18 - only apply on Raspberry Pi hardware
  # This overlay connects the PPS signal to the kernel's timing subsystem
  # - Uses GPIO 18 (physical pin 12) as the PPS input
  # - Configures as input with no pull-up/down resistors
  hardware.deviceTree.overlays = lib.mkIf (config.hardware ? raspberry-pi) [
    {
      name = "pps-gpio-overlay";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        / {
          compatible = "brcm,bcm2711";
          fragment@0 {
            target-path = "/";
            __overlay__ {
              pps: pps@12 {
                compatible = "pps-gpio";
                pinctrl-names = "default";
                pinctrl-0 = <&pps_pins>;
                gpios = <&gpio 18 0>;
                status = "okay";
              };
            };
          };

          fragment@1 {
            target = <&gpio>;
            __overlay__ {
              pps_pins: pps_pins@12 {
                brcm,pins = <18>;
                brcm,function = <0>;
                brcm,pull = <0>;
              };
            };
          };

          __overrides__ {
            gpiopin = <&pps>,"gpios:4",
                <&pps>,"reg:0",
                <&pps_pins>,"brcm,pins:0",
                <&pps_pins>,"reg:0";
            assert_falling_edge = <&pps>,"assert-falling-edge?";
            capture_clear = <&pps>,"capture-clear?";
            pull = <&pps_pins>,"brcm,pull:0";
          };
        };
      '';
    }
  ];

  # Essential tools for GPS configuration and debugging
  environment.systemPackages = with pkgs; [
    gpsd       # GPS daemon and client tools
    pps-tools  # PPS monitoring and testing utilities
  ];
}