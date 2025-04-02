{
  pkgs ? (import ../../nixpkgs.nix) { },
}:
{
  # Development tools
  nixfmt-plus = pkgs.callPackage ./nixfmt-plus.nix { };

  # Shell enhancements
  zsh-histdb-skim = pkgs.callPackage ./zsh-histdb-skim.nix { };

  # Reserved for future packages
  # example = pkgs.callPackage ./example.nix { };
}
