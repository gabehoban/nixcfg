{ lib, ... }:
{
  # Host-related helper functions
  relativeToRoot = lib.path.append ../.;
}
