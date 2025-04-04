# parts/devshells.nix
#
# Development shells configuration for the flake
{ inputs, ... }: 
{
  perSystem = { config, self', inputs', pkgs, system, ... }: {
    # Development shell for this project
    devShells.default = pkgs.mkShell {
      packages = [
        inputs.agenix-rekey.packages.${system}.default
        pkgs.age-plugin-yubikey
        pkgs.rage
        inputs.deploy-rs.packages.${system}.deploy-rs
      ];
    };
  };
}