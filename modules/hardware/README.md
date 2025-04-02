# Hardware

This directory contains modules for configuring specific hardware components and platforms.

## Modules

- `default.nix`: Core hardware detection and configuration
- `hw-cpu-amd.nix`: Configuration optimized for AMD CPUs
- `hw-gpu-amd.nix`: Configuration for AMD GPUs with appropriate drivers

## Usage

Import hardware modules in your host configuration based on the specific hardware components:

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/hardware/hw-cpu-amd.nix
    ./modules/hardware/hw-gpu-amd.nix
  ];
}
```

For most cases, you should create hardware profiles in the `profiles/hardware/` directory that import the appropriate hardware modules for common hardware combinations.

## Adding New Hardware Support

When adding support for new hardware:

1. Create a new file following the `hw-[component]-[vendor].nix` naming convention
2. Include detailed comments about the hardware components supported
3. Add appropriate kernel modules, firmware, and configuration options
4. Ensure compatibility with existing hardware modules
