{
  pkgs ? (import ../../nixpkgs.nix) { },
}:
{
  # Shell enhancement packages
  zsh-histdb-skim = pkgs.callPackage ./zsh-histdb-skim.nix { };
}
