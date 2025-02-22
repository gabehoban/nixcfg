{config, ...}: {
  boot.extraModulePackages = [
    (config.boot.kernelPackages.callPackage ./kernel-module.nix {})
  ];
  boot.blacklistedKernelModules = ["r8169"];
}
