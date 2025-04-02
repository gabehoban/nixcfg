# Users

This directory contains modules for configuring user accounts and their environments.

## Modules

- `gabehoban.nix`: User configuration for gabehoban

## Usage

Import user modules in your host configuration:

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/users/gabehoban.nix
    # Additional modules
  ];
}
```

## User Module Structure

Each user module should:

1. Define the user account with appropriate groups and permissions
2. Configure user-specific packages and applications
3. Set up dotfiles and configuration files
4. Configure shell and environment variables
5. Set user-specific service configurations

## Adding New Users

To add a new user:

1. Create a new file named after the username
2. Follow the structure of existing user modules
3. Configure user-specific settings and applications
4. Ensure appropriate permissions and group memberships
