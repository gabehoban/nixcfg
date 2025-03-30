# profiles/hardware/amd-desktop.nix
#
# Profile for AMD desktop hardware configuration
{
  configLib,
  ...
}: {
  imports = [
    # CPU and GPU modules
    (configLib.moduleImport "hardware/hw-cpu-amd.nix")
    (configLib.moduleImport "hardware/hw-gpu-amd.nix")
  ];

  # Enable AMD-specific firmware and drivers
  hardware.enableRedistributableFirmware = true;
}