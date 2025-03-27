{ lib, ... }:

# ==================== HELPER FUNCTION IMPORTS ====================
let
  # System-related helpers
  systemLib = import ./system.nix { inherit lib; };

  # Host-related helpers
  hostsLib = import ./hosts.nix { inherit lib; };

  # Package-related helpers
  pkgsLib = import ./pkgs.nix { inherit lib; };
in

# ==================== PUBLIC API ====================
{
  # System configuration helpers
  inherit (systemLib)
    forAllSystems
    ;

  # Host configuration helpers
  inherit (hostsLib)
    relativeToRoot
    ;

  # Package management helpers
  inherit (pkgsLib)
    importPackagesByCategory
    ;

  # Additional utility functions can be added here
}
