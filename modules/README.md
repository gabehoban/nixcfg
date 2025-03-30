# Modules

This directory contains all NixOS modules used across different hosts. Each module represents a specific functionality or configuration aspect.

## Organization

- `core/`: Essential system modules that provide basic functionality
- `hardware/`: Hardware-specific configurations (CPUs, GPUs, etc.)
- `desktop/`: Desktop environments and related configurations
- `services/`: System service configurations
- `applications/`: Software application configurations
- `users/`: User profile configurations

## Usage

Modules should be small, focused, and well-documented. Each module should:

1. Have a clear, specific purpose
2. Include appropriate documentation
3. Be as atomic as possible
4. Have minimal dependencies on other modules

Import modules selectively in your host configurations or profiles, rather than including entire directories by default.
