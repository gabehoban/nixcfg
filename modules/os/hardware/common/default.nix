{
  config,
  lib,
  self,
  ...
}: {
  config = {
    console.useXkbConfig = true;

    hardware = {
      enableAllFirmware = true;

      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      keyboard.qmk.enable = true;

      logitech.wireless = {
        enable = true;
        enableGraphical = lib.mkDefault config.services.xserver.enable;
      };
    };

    services = {
      fstrim.enable = true;

      logind = {
        powerKey = "suspend";
        powerKeyLongPress = "poweroff";
      };
    };

    zramSwap.enable = lib.mkDefault true;
  };
}