# modules/core/lib.nix
#
# Shared library functions for NixOS modules
{ lib, ... }:

{
  # Make our custom lib functions available to all modules
  _module.args.configLib = let 
    # Import the project's full lib utilities
    projectLib = import ../../lib { inherit lib; };
  in
    projectLib;
}