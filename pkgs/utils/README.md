# Utility Packages

This directory contains utility packages that don't fit into other categories.

## Adding a New Package

To add a new utility package:

1. Create a new `.nix` file in this directory
2. Add the package to the `default.nix` file in this directory
3. The package will be automatically available in the flake outputs

## Package Structure

Each package should follow this general structure:

```nix
{
  lib,
  stdenv,
  # Other dependencies...
}:
stdenv.mkDerivation rec {
  pname = "package-name";
  version = "0.1.0";
  
  src = fetchFromGitHub {
    owner = "username";
    repo = "repo-name";
    rev = "commit-or-tag";
    sha256 = "sha256-hash";
  };
  
  # Build and install phases...
  
  meta = with lib; {
    description = "Package description";
    homepage = "https://github.com/username/repo-name";
    license = licenses.mit;  # Or appropriate license
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
```
