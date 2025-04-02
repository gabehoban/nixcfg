# nix build .#nixosConfigurations.iso-workstation.config.system.build.isoImage
{
  description = "Workstation NixOS installation";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { nixpkgs, ... }:
    let
      common = import ./default.nix;
    in
    {
      nixosConfigurations = {
        iso-workstation = common.mkInstallationImage {
          hostName = "workstation";
          extraModules = [
            (
              { config, pkgs, ... }:
              {
                # Enable r8125 network module
                boot.extraModulePackages = [
                  (config.boot.kernelPackages.callPackage
                    ../hosts/workstation/hardware/network/realtek-r8125-module.nix
                    { }
                  )
                ];
                boot.blacklistedKernelModules = [ "r8169" ];
                # Enable Yubikey for secrets decryption
                services.pcscd.enable = true;
                services.udev.packages = [ pkgs.yubikey-personalization ];
              }
            )
          ];
        } { inherit nixpkgs; };
      };
    };
}
