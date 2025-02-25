{
  config,
  lib,
  ...
}: {
  options.myNixOS.programs.nix.enable = lib.mkEnableOption "sane nix configuration";

  config = lib.mkIf config.myNixOS.programs.nix.enable {
    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
        persistent = true;
        randomizedDelaySec = "60min";
      };

      # Run GC when there is less than 1GiB left.
      extraOptions = ''
        min-free = ${toString (1 * 1024 * 1024 * 1024)}   # 1 GiB
        max-free = ${toString (5 * 1024 * 1024 * 1024)}   # 5 GiB
      '';

      optimise = {
        automatic = true;
        persistent = true;
        randomizedDelaySec = "60min";
      };

      settings = {
        experimental-features = ["nix-command" "flakes"];

        substituters = [
          "https://cache.nixos.org/"
          "https://gabehoban.cachix.org"
          "https://chaotic-nyx.cachix.org/"
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "gabehoban.cachix.org-1:8KJ3WRVyJGR7/Ghf1qol4pCqmmGuxNNpedDneyivky4="
          "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8"
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        trusted-users = ["@wheel"];
      };
    };

    programs.nix-ld.enable = true;
  };
}
