{ config, ... }: {
  # Custom Raspberry Pi configuration for boot
  # Using generic-extlinux instead of U-Boot (configured in hardware/default.nix)

  # Add custom device tree settings
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
    {
      name = "pps-gpio";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        / {
          compatible = "raspberrypi,4-model-b";

          fragment@0 {
            target-path = "/";
            __overlay__ {
              pps {
                compatible = "pps-gpio";
                gpios = <&gpio 18 0>;
                status = "okay";
              };
            };
          };
        };
      '';
    }
    # Enable UART interface
    {
      name = "enable-uart";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        / {
          compatible = "raspberrypi,4-model-b";

          fragment@0 {
            target = <&uart0>;
            __overlay__ {
              status = "okay";
            };
          };
        };
      '';
    }
    # Disable Bluetooth to free up UART
    {
      name = "disable-bt";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        / {
          compatible = "raspberrypi,4-model-b";

          fragment@0 {
            target = <&uart1>;
            __overlay__ {
              status = "disabled";
            };
          };

          fragment@1 {
            target = <&bluetooth>;
            __overlay__ {
              status = "disabled";
            };
          };
        };
      '';
    }
  ];

  # Make sure the I2C interface is available
  # This is needed for the RTC
  hardware.i2c.enable = true;

  # Additional configurations for the Raspberry Pi via device tree
  # (apply-overlays-dtmerge.enable is set in default.nix)
  hardware.deviceTree.filter = "bcm2711-rpi-4-*.dtb";
  
  # Consolidated kernel parameters for the Raspberry Pi
  boot.kernelParams = [
    # Enable UART hardware but disable Bluetooth
    "enable_uart=1"
    "dtoverlay=disable-bt"
    # Use only the display console, not the UART/serial console
    # but keep UART hardware enabled for GPS
    "console=tty0"

    # Disable console on UART but keep hardware enabled
    "consoleblank=0" # Prevent console blanking
    "quiet" # Reduce boot messages
    "loglevel=3" # Only show important messages

    # Disable serial console explicitly
    "earlycon=off" # Disable early serial console

    # Serial port settings for GPS
    "uart_baud=115200"

    # Disable dynamic ticks for better timing accuracy
    "nohz=off"

    # Add basic Pi4 video console parameters
    "video=HDMI-A-1:1280x720@60"
  ];
}
