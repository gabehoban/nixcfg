# hosts/rpi-casio/hardware/rpi-config.nix
#
# rpi-casio-specific Raspberry Pi hardware configuration
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  # RTC on I2C bus for timekeeping backup
  hardware.deviceTree.overlays = [
    {
      name = "i2c-rtc";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        / {
          compatible = "raspberrypi,4-model-b";

          fragment@0 {
            target = <&i2c1>;
            __overlay__ {
              status = "okay";
              #address-cells = <1>;
              #size-cells = <0>;

              rv3028: rv3028@52 {
                compatible = "microcrystal,rv3028";
                reg = <0x52>;
                wakeup-source;
                backup-switchover-mode = <3>;
              };
            };
          };
        };
      '';
    }
    # Bluetooth disabled to free UART for GPS
    {
      name = "disable-bt";
      dtboFile = ./overlays/disable-bt.dtbo;
    }
  ];

  # Enable I2C for RTC connection
  hardware.i2c.enable = true;
  hardware.deviceTree.filter = "bcm2711-rpi-4-*.dtb";

  # Kernel parameters optimized for GPS timing accuracy
  boot.kernelParams = [
    "console=tty0"
    "consoleblank=0"
    "init_uart_baud=115200"
    "8250.nr_uarts=1"
    "nohz=off"
    "video=HDMI-A-1:1280x720@60"
  ];
}
