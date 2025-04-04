# parts/agenix.nix
#
# Agenix and agenix-rekey configuration
{ inputs, self, ... }:
{
  # Make agenix-rekey available as a perSystem flake output
  perSystem = _: {
    # Define deployment tools and other per-system outputs
  };

  # Make agenix-rekey available as a top-level flake output
  flake = {
    # Configure agenix-rekey
    agenix-rekey = inputs.agenix-rekey.configure {
      userFlake = self;
      inherit (self) nixosConfigurations;
    };
  };
}