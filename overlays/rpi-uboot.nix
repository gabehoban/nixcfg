{ pkgs, ... }:
final: prev:

{
  # Override uboot for Raspberry Pi to ignore UART interrupts
  # during boot process
  ubootRaspberryPi4_64bit = prev.ubootRaspberryPi4_64bit.overrideAttrs (old: {
    extraConfig = ''
      # Ignore UART interrupts during boot process
      CONFIG_AUTOBOOT=y
      CONFIG_AUTOBOOT_KEYED=y
      CONFIG_AUTOBOOT_DELAY_STR=""
      CONFIG_AUTOBOOT_STOP_STR=""
      # Set boot delay to minimal value, but not zero
      CONFIG_BOOTDELAY=1
      # Ensure boot continues regardless of UART input
      CONFIG_BOOT_RETRY_TIME=1
      CONFIG_BOOT_RETRY_MIN=1
      CONFIG_RESET_TO_RETRY=y
      # Disable interactive boot
      CONFIG_SILENT_CONSOLE=y
      CONFIG_SILENT_U_BOOT_ONLY=y
    '';

    # Apply patches if needed
    patches = (old.patches or [ ]) ++ [
      # Add any custom patches here if needed
    ];
  });
}
