# ───────────────────────────────────────────
# Realtek R8125 2.5G Network Driver Configuration
# ───────────────────────────────────────────
{
  config,
  ...
}:
{
  # Custom module for Realtek 2.5G network adapter (RTL8125)
  # This works around compatibility issues with the default r8169 driver
  boot = {
    # Load custom driver module from the local definition
    extraModulePackages = [
      (config.boot.kernelPackages.callPackage ./realtek-r8125-module.nix { })
    ];

    # Blacklist the default r8169 driver which conflicts with r8125
    blacklistedKernelModules = [ "r8169" ];
  };
}
