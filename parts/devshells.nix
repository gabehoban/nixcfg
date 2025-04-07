# parts/devshells.nix
#
# Development shells configuration for the flake
{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      # Development shell for this project
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.attic-client
          inputs.agenix-rekey.packages.${system}.default
          pkgs.age-plugin-yubikey
          pkgs.rage
          inputs.deploy-rs.packages.${system}.deploy-rs
        ];
      };
    };
}
