# modules/[MODULE_PATH].nix
#
# [MODULE_NAME]: [SHORT_DESCRIPTION]
# [LONGER_DESCRIPTION_IF_NEEDED - WHY THIS MODULE EXISTS]
{ config, lib, pkgs, ... }:

# This module follows the flattened pattern - configuration is applied directly when imported
{
  # Core implementation
  # service.example = {
  #   enable = true;
  #   # Additional settings...
  # };
  
  # Conditional configuration - only apply when dependencies exist
  # Prefer 'or false' pattern for defensive programming when checking optional config
  # services.dependent = lib.mkIf (config.services.required.enable or false) {
  #   enable = true;
  # };
  
  # Check for platform/hardware features using hasAttr pattern when necessary
  # hardware.specialFeature = lib.mkIf (config.hardware ? platform-type) {
  #   # Platform-specific settings...
  # };
  
  # Include packages related to this functionality
  # environment.systemPackages = with pkgs; [
  #   package1    # Purpose of this package
  #   package2    # Why this package is included
  # ];
}