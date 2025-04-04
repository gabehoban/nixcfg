# hosts/sekio/optimization.nix
#
# SD card optimizations for Raspberry Pi
{ lib, ... }:

{
  # Use Raspberry Pi optimizations module for SD card write reduction
  # All actual optimizations are defined in the module and activated here
  hardware.raspberry-pi = {
    # SD card and power optimizations
    optimizeForSD = true;
    enableZramSwap = true;
    volatileLogs = true;
    enablePowerSaving = true;
  };
}