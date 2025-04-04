{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Custom Raspberry Pi configuration through boot.loader.generic-extlinux-compatible
  boot.loader.generic-extlinux-compatible.configurationLimit = 1;
  
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
  ];
  
  # Make sure the I2C interface is available
  # This is needed for the RTC
  hardware.i2c.enable = true;
  
  # Additional configurations for the Raspberry Pi via device tree
  hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;
  hardware.deviceTree.filter = "bcm2711-rpi-4-*.dtb";
  
  # Consolidated kernel parameters for the Raspberry Pi
  boot.kernelParams = [
    # Use only the display console, not the UART/serial console
    # since the GPS HAT uses these pins
    "console=tty0"
    
    # Serial port settings for GPS
    "uart_baud=115200"
    
    # Disable dynamic ticks for better timing accuracy
    "nohz=off"
  ];
}