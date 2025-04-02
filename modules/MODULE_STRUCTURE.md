# Module Structure Guidelines

This document describes the standardized structure for all NixOS modules in this repository.

## Module Header

Every module should begin with a standardized header that includes the file path and a brief description:

```nix
# modules/category/module-name.nix
#
# Brief description of the module's purpose
```

## Function Arguments

Function arguments should be consistently formatted, with one argument per line for better readability and easier maintenance:

```nix
{ 
  config,
  lib, 
  pkgs,
  ...
}:
```

## Section Comments

All modules should use clear section headers to organize related code. The standard format is:

```nix
#
# Section name
#
```

## Package Lists

Package lists should be organized using one of these approaches:

1. **Alphabetical order**: For simple lists of related packages
2. **Functional grouping**: For larger lists, group by function with comments

Each package should have a brief comment explaining its purpose, especially for non-obvious packages:

```nix
environment.systemPackages = with pkgs; [
  # Development tools
  git              # Version control system
  neovim           # Text editor
  
  # System utilities
  htop             # Process viewer
  ripgrep          # Fast text search
];
```

## Persistence Configuration

For modules that require data persistence across reboots:

1. Place persistence configuration in a dedicated section at the end of the module
2. Use the standard section header: `# Persistence configuration`
3. Clearly document what data is being persisted and why

```nix
#
# Persistence configuration
#
environment.persistence."/persist" = {
  users.username = {
    directories = [
      # Configuration directories
      ".config/application"
    ];
  };
};
```

## Comments

Use clear, concise comments to explain:

1. **Non-obvious settings**: Why a particular configuration was chosen
2. **Workarounds**: Any workarounds for specific issues
3. **Dependencies**: Important dependencies between settings

Comments should be placed directly above the code they describe, or at the end of the line for simple settings.

## Example Module Structure

```nix
# modules/category/module-name.nix
#
# Brief description of the module's purpose
{ 
  config,
  lib, 
  pkgs,
  ...
}:

{
  #
  # Main configuration section
  #
  settings = {
    # Configuration with explanatory comments
    option1 = true;   # Enable feature X
    option2 = "value"; # Use specific value for Y
  };

  #
  # Package definitions
  #
  environment.systemPackages = with pkgs; [
    # Development tools
    package1    # Purpose of package1
    package2    # Purpose of package2
  ];

  #
  # Persistence configuration
  #
  environment.persistence."/persist" = {
    # System-level persistence
    directories = [
      # Directories to persist
    ];
    
    # User-level persistence
    users.username = {
      directories = [
        # User directories to persist
      ];
    };
  };
}
```

## Best Practices

1. **Be Consistent**: Follow the same structure and style across all modules
2. **Group Related Settings**: Keep related configuration options together
3. **Document Non-Obvious Choices**: Add comments for choices that aren't self-explanatory
4. **Use Meaningful Names**: Choose descriptive names for options and variables
5. **Keep Modules Focused**: Each module should have a clear, specific purpose
6. **Follow Existing Patterns**: When modifying existing modules, follow the patterns already established