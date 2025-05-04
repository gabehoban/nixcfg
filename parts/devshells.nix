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
          # Deployment and secrets
          pkgs.attic-client
          inputs.agenix-rekey.packages.${system}.default
          pkgs.age-plugin-yubikey
          pkgs.rage
          inputs.deploy-rs.packages.${system}.deploy-rs

          # Code quality tools
          pkgs.statix
          pkgs.pre-commit

          # Development utilities
          pkgs.git
        ];

        shellHook = ''
          echo "✨ NixOS Configuration Development Environment ✨"
          echo ""
          echo "Code Quality Tools:"
          echo "  ./scripts/check-style.sh - Check code style compliance"
          echo "  ./scripts/new-module.sh  - Generate new module from template"
          echo "  nixfmt-plus             - Format Nix files"
          echo "  statix check            - Lint Nix files"
          echo ""
          echo "Setup pre-commit hooks with: pre-commit install"
          echo ""
        '';
      };
    };
}
