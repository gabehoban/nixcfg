# parts/agenix.nix
#
# Agenix and agenix-rekey configuration
{ inputs, self, ... }:
{
  flake = {
    # Agenix-rekey configuration
    agenix-rekey = inputs.agenix-rekey.configure {
      userFlake = self;
      inherit (self) nixosConfigurations;
    };
  };
}