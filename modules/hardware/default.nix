# modules/hardware/default.nix
#
# Combined hardware modules
# Imports all hardware-related modules
{
  ...
}:
{
  #
  # Hardware-specific modules
  #
  imports = [
    # CPU modules
    ./hw-cpu-amd.nix # AMD CPU optimizations

    # GPU modules
    ./hw-gpu-amd.nix # AMD GPU drivers and configuration
  ];

  # This module serves as an aggregator for hardware-specific configurations
  # for different system components (CPU, GPU, storage, etc.).
  #
  # To add a new hardware component configuration:
  # 1. Create a new file named hw-component-vendor.nix (e.g., hw-storage-samsung.nix)
  # 2. Add hardware-specific configuration following the module pattern
  # 3. Import the new file in this default.nix
  #
  # For platform-specific configurations (like Raspberry Pi):
  # - Use platform-specific modules like hw-platform-rpi.nix
  # - These can be selectively imported directly into host configurations
}
