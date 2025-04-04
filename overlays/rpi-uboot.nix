_: _final: prev:

{
  # Override uboot for Raspberry Pi to fix boot issues and ignore UART interrupts
  ubootRaspberryPi4_64bit = prev.ubootRaspberryPi4_64bit.overrideAttrs (old: {
    # Configure U-Boot to ignore serial input and auto-boot without waiting
    extraConfig = ''
      CONFIG_AUTOBOOT=y
      CONFIG_BOOTDELAY=-2
    '';

    # Ensure patches don't interfere
    patches = old.patches or [ ];
  });

  # Modify the module closure to allow missing modules during build
  # This is critical for cross-compilation of Raspberry Pi images
  makeModulesClosure =
    args:
    prev.makeModulesClosure (
      args
      // {
        # Allow the build to continue even if some modules are missing
        allowMissing = true;
      }
    );
}
