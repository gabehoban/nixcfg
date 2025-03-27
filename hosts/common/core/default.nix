# Main configuration file for common system settings
# Imports all core modules and sets global system parameters
{ ... }:
{
  # Import core module categories
  imports = [
    ./system # System-level configurations (boot, locale, etc.)
    ./network # Network-related configurations
    ./environment # User environment configurations (packages, shell, etc.)
    ./services # System services configurations
  ];

  # Enable all firmware (including non-free firmware)
  hardware.enableAllFirmware = true;

  # NixOS system state version
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
