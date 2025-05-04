# pkgs/all/zsh-histdb-skim.nix
#
# Zsh history database searcher with skim integration
# Provides fast fuzzy search through shell history using histdb
{
  fetchFromGitHub,
  rustPlatform,
  sqlite,
}:
rustPlatform.buildRustPackage rec {
  pname = "zsh-histdb-skim";
  version = "0.8.6";

  buildInputs = [ sqlite ];
  src = fetchFromGitHub {
    owner = "m42e";
    repo = "zsh-histdb-skim";
    rev = "v${version}";
    hash = "sha256-lJ2kpIXPHE8qP0EBnLuyvatWMtepBobNAC09e7itGas=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-dqTYJkKnvjzkV124XZHzDV58rjLhNz+Nc3Jj5gSaJas=";

  patchPhase = ''
    substituteInPlace zsh-histdb-skim-vendored.zsh \
      --replace zsh-histdb-skim "$out/bin/zsh-histdb-skim"
  '';

  postInstall = ''
    mkdir -p $out/share/zsh-histdb-skim
    cp zsh-histdb-skim-vendored.zsh $out/share/zsh-histdb-skim/zsh-histdb-skim.plugin.zsh
  '';
}
