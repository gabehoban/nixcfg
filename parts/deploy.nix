# parts/deploy.nix
#
# Deploy-rs configuration for remote deployment
# Integrated directly with flake-parts
{ inputs, self, ... }:
{
  # Add checks for deploy-rs
  flake = {
    checks = builtins.mapAttrs 
      (system: deployLib: deployLib.deployChecks self.deploy) 
      inputs.deploy-rs.lib;
  };
  
  # Define deploy output for deploy-rs
  flake.deploy = {
    nodes = {
      sekio = {
        hostname = "sekio.local";
        sshUser = "gabehoban";
        profiles = {
          system = {
            user = "root";
            path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.sekio;
            sshOpts = [ "-t" ]; # Required for sudo password prompt
            magicRollback = true; 
            remoteBuild = false; 
            autoRollback = true;
            confirmTimeout = 300;
          };
        };
        fastConnection = false;
      };
    };
  };
}