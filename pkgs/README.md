# Custom Packages

This directory contains custom package definitions that are not available in Nixpkgs or require modifications for this system.

## Organization

- `all/`: Contains all custom package definitions
  - `nixfmt-plus.nix`: Enhanced Nix formatter
  - `zsh-histdb-skim.nix`: ZSH history database with skim integration
- `default.nix`: Exports all packages

## Adding New Packages

To add a new custom package:

1. Create a new file in the `all/` directory
2. Implement your package definition using the Nixpkgs packaging conventions
3. Add your package to `all/default.nix`
4. Ensure it's properly exported in the root `default.nix`

## Usage

These packages are automatically made available to all system configurations via the flake outputs.

To use a custom package in a module or configuration:

```nix
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Regular Nixpkgs packages
    git
    vim
    
    # Custom packages
    nixfmt-plus
    zsh-histdb-skim
  ];
}
```
