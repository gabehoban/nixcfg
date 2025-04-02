# Overlays

This directory contains custom Nixpkgs overlays that modify or extend packages available to the system.

## Files

- `default.nix`: Combines and exports all overlays
- `packages.nix`: Overlays for specific package modifications

## Usage

Overlays are automatically loaded in `flake.nix` and applied to the Nixpkgs instance used for building system configurations.

To add a new overlay:

1. Create a new file in this directory or modify an existing one
2. Ensure your overlay is imported in `default.nix`
3. Document the purpose and changes made by your overlay with comments

## Example

A simple overlay to override a package version might look like:

```nix
final: prev: {
  # Override the Firefox package with a custom configuration
  firefox = prev.firefox.override {
    # Custom configuration options
    cfg = {
      enableTridactylNative = true;
    };
  };
}
```
