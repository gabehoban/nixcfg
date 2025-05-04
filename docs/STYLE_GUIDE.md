# Nix Code Style Guide

This document defines the coding standards and best practices for all Nix modules in this repository.

## File Structure

### Module Header
Every Nix module should start with a descriptive header comment:

```nix
# modules/category/module-name.nix
#
# Brief description of what this module does
# Additional context or important notes
```

### Function Arguments
Use explicit argument destructuring with clear formatting:

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
```

## Library Usage

### Prefer Explicit `lib.` Prefix
Instead of using `with lib;`, use explicit `lib.` prefixes for clarity and to avoid namespace pollution:

```nix
# Good
lib.mkOption {
  type = lib.types.bool;
  default = false;
  description = lib.mdDoc "Enable feature X";
}

# Avoid
with lib;
mkOption {
  type = types.bool;
  default = false;
  description = mdDoc "Enable feature X";
}
```

### Exception for `pkgs`
It's acceptable to use `with pkgs;` when defining lists of packages:

```nix
environment.systemPackages = with pkgs; [
  git
  vim
  firefox
];
```

## Variable Naming

### Consistent Conventions
- Use camelCase for local variables: `myVariable`
- Use kebab-case for module names: `my-module.nix`
- Use descriptive names that indicate purpose

### Configuration Options
When defining module options, use clear, hierarchical naming:

```nix
options.services.myService = {
  enable = lib.mkEnableOption (lib.mdDoc "my service");

  settings = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = lib.mdDoc "Configuration for my service";
  };
};
```

## Documentation

### Module Documentation
- Every module must have a header comment explaining its purpose
- Complex functionality should include inline comments
- Use `lib.mdDoc` for option descriptions

### Comment Style
```nix
# Single-line comment for brief explanations

#
# Section header for grouping related configuration
#

# Multi-line explanation for complex logic
# continues on multiple lines when needed
# to fully explain the concept
```

### Option Descriptions
Always provide meaningful descriptions for module options:

```nix
options = {
  myOption = lib.mkOption {
    type = lib.types.str;
    default = "value";
    description = lib.mdDoc ''
      Detailed description of what this option does
      and how it affects the system behavior.
    '';
  };
};
```

## Code Organization

### Grouping
Group related configuration together with section comments:

```nix
#
# Logging configuration
#
services.myService.logging = {
  level = "info";
  format = "json";
};

#
# Performance settings
#
services.myService.performance = {
  workers = 4;
  maxConnections = 1000;
};
```

### Let Bindings
Use `let...in` for complex expressions or repeated values:

```nix
let
  commonSettings = {
    timeout = 30;
    retries = 3;
  };

  dbConfig = {
    host = "localhost";
    port = 5432;
  };
in {
  services.app1.settings = commonSettings;
  services.app2.settings = commonSettings // dbConfig;
}
```

## Best Practices

### Assertions
Add assertions for critical configuration requirements:

```nix
assertions = [
  {
    assertion = config.services.myService.enable -> config.networking.firewall.enable;
    message = "myService requires the firewall to be enabled";
  }
];
```

### Avoid Magic Numbers
Use named variables for numeric values:

```nix
let
  maxConnections = 1000;
  timeoutSeconds = 30;
in {
  services.myService = {
    connections = maxConnections;
    timeout = timeoutSeconds;
  };
}
```

### Module Imports
Keep imports organized and documented:

```nix
imports = [
  # Core functionality
  ./core.nix

  # Service configurations
  ./services/web.nix
  ./services/database.nix

  # Hardware-specific settings
  ./hardware/gpu.nix
];
```

## Error Handling

### Meaningful Error Messages
Provide helpful error messages in assertions:

```nix
assertions = [
  {
    assertion = config.services.database.type == "postgresql" ->
      config.services.database.version >= 14;
    message = "PostgreSQL version must be 14 or higher when using PostgreSQL as database type";
  }
];
```

## Module Templates

### Service Module Template
```nix
# modules/services/service-name.nix
#
# Description of the service and its purpose
#
{ config, lib, pkgs, ... }:

let
  cfg = config.services.serviceName;
in {
  options.services.serviceName = {
    enable = lib.mkEnableOption (lib.mdDoc "service name");

    # Additional options...
  };

  config = lib.mkIf cfg.enable {
    # Service configuration...
  };
}
```

### Application Module Template
```nix
# modules/applications/app-name.nix
#
# Application description and purpose
#
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    appName
  ];

  # Additional configuration...
}
```

## Formatting

### Indentation
- Use 2 spaces for indentation
- Align nested attributes properly

### Line Length
- Keep lines under 100 characters when possible
- Break long expressions into multiple lines

### Whitespace
- Use blank lines to separate logical sections
- No trailing whitespace
- Single blank line at end of file

## Linting and Validation

Use `nixfmt-plus` for consistent formatting:

```bash
# Format a single file
nixfmt-plus module.nix

# Format all Nix files
fd -e nix -x nixfmt-plus {}
```

## Enforcement

These standards are enforced through:
1. Pre-commit hooks for formatting
2. CI pipeline validation
3. Code review requirements
