# modules/hardware/default.nix
#
# Combined hardware modules
# Imports all hardware-related modules
{
  imports = [
    # CPU modules
    ./hw-cpu-amd.nix
    
    # GPU modules
    ./hw-gpu-amd.nix
  ];
}