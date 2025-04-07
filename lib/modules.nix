# lib/modules.nix
# Helper functions for working with modules and profiles
{ lib, ... }:

let
  # Base directories for modules and profiles
  modulesDir = ../modules;
  profilesDir = ../profiles;
in
{
  # Import a module from the modules directory
  # Example: moduleImport "core/boot.nix"
  moduleImport = path: lib.path.append modulesDir path;

  # Import a profile from the profiles directory
  # Example: profileImport "desktop/gnome.nix"
  profileImport = path: lib.path.append profilesDir path;

  # Create a new attrset with only the specified attributes from original
  # Useful for selectively including modules
  selectAttrs = original: attrs: lib.attrsets.genAttrs attrs (name: original.${name});

  # Function to merge a list of module sets together
  # Example: mergeModuleSets [ coreModules networkModules desktopModules ]
  mergeModuleSets = moduleSetsList: lib.foldl' lib.recursiveUpdate { } moduleSetsList;

  # Group modules from a directory into a categorized attrset
  # Useful for organizing modules logically
  groupModules =
    baseDir: lib.mapAttrs (name: _: import (lib.path.append baseDir name)) (builtins.readDir baseDir);

  # Helper function to check if impermanence is enabled in a host
  hasImpermanence =
    config: config ? environment.persistence && builtins.typeOf config.environment.persistence == "set";

  # Helper to make an impermanence configuration conditional
  # This creates a simple conditional attrset that only activates when impermanence is available
  mkImpermanenceConfig =
    {
      directories ? [ ],
      files ? [ ],
      users ? { },
    }:
    self:
    if self.hasImpermanence self.config then
      {
        environment.persistence."/persist" = {
          inherit directories files users;
        };
      }
    else
      { };

}
