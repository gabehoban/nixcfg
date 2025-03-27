# Environment Configuration

This directory contains user environment configurations for the NixOS system.

## Files

- **packages.nix** - System-wide packages
  - Essential utilities (git, rsync, wget, etc.)
  - Improved CLI tools (bat, eza, duf)
  - System utilities
  - Filesystem tools
  - Nix helper tools

- **dev.nix** - Development tools and languages
  - Language servers
  - Formatters
  - Linters
  - Compilers and linkers
  - Development utilities
  - Programming languages

- **zsh.nix** - ZSH shell configuration
  - Default user shell settings
  - ZSH plugins and options
  - History configuration
  - Completion settings
  - ZSH key bindings

- **starship.nix** - Starship prompt configuration
  - Prompt format and styling
  - Status indicators
  - Git information display
  - Performance settings

## Usage

Include the entire environment module or specific components:

```nix
# Include all environment components
imports = [ ./environment ];

# Or import specific files
imports = [
  ./environment/packages.nix
  ./environment/dev.nix
];
```

## Adding New Environment Components

When adding new environment components:

1. For user-specific configurations, consider using home-manager
2. For system-wide tools, add them to packages.nix
3. For development-specific tools, add them to dev.nix
4. For shell customizations, add them to zsh.nix or starship.nix
5. For large new features, create a dedicated file and import it in default.nix
