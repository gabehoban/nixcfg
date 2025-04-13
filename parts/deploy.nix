# parts/deploy.nix
#
# Deploy-rs configuration for remote deployment
# Integrated directly with flake-parts
{ inputs, self, ... }:
{
  # Add checks for deploy-rs
  flake = {
    checks = builtins.mapAttrs (
      _system: deployLib: deployLib.deployChecks self.deploy
    ) inputs.deploy-rs.lib;
  };

  # Define deploy output for deploy-rs
  flake.deploy = {
    nodes = {
      # Intel NUC Homelab servers (x86_64-linux)
      nuc-luna = {
        hostname = "nuc-luna.local";
        sshUser = "gabehoban";
        profiles = {
          system = {
            user = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nuc-luna;
            magicRollback = true;
            remoteBuild = false;
            autoRollback = true;
            confirmTimeout = 300;
          };
        };
        fastConnection = true;
      };

      nuc-juno = {
        hostname = "nuc-juno.local";
        sshUser = "gabehoban";
        profiles = {
          system = {
            user = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nuc-juno;
            magicRollback = true;
            remoteBuild = false;
            autoRollback = true;
            confirmTimeout = 300;
          };
        };
        fastConnection = true;
      };

      nuc-titan = {
        hostname = "nuc-titan.local";
        sshUser = "gabehoban";
        profiles = {
          system = {
            user = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nuc-titan;
            magicRollback = true;
            remoteBuild = false;
            autoRollback = true;
            confirmTimeout = 300;
          };
        };
        fastConnection = true;
      };
    };
  };
}
