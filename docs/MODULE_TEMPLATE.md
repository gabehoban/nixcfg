# Module Template and Coding Standards

This document provides a template and coding standards for creating modules in this NixOS configuration repository.

## Module Template

All new modules should follow this template structure:

```nix
# modules/<category>/<module-name>.nix
#
# <Brief one-line description>
#
# <Detailed multi-line description explaining the purpose, key features,
# and any important implementation details>
{ pkgs, ... }:

{
  # Module implementation here
  # Example:
  # environment.systemPackages = [ pkgs.something ];
  # systemd.services.something = { ... };
}
```

## Coding Standards

### 1. Documentation

* Every module MUST have a header comment with:
  * A one-line description
  * A detailed multi-line description (for complex modules)

### 2. File Organization

* Use appropriate directory for the module's category
* Use kebab-case for file names (e.g., `hw-platform-rpi.nix`)
* Group related files in subdirectories when appropriate

### 3. Implementation Style

* Directly declare settings without conditional wrappers
* Group related settings together with comments
* Prefer declarative configuration over imperative
* Document any side effects or interactions with other modules

### 4. Code Formatting

* Use 2-space indentation
* Keep imports minimal - only include what's needed
* Use consistent naming for similar concepts
* Add explanatory comments for complex settings

## Examples

### Basic Module Example

```nix
# modules/services/chrony.nix
#
# NTP time synchronization service
#
# Configures Chrony for accurate timekeeping with optimized settings
# for network time synchronization.
{ pkgs, ... }:

{
  # Install chrony package
  environment.systemPackages = [ pkgs.chrony ];
  
  # Configure chrony service
  services.chrony = {
    # Use pool.ntp.org servers
    servers = [
      "0.pool.ntp.org"
      "1.pool.ntp.org"
      "2.pool.ntp.org"
      "3.pool.ntp.org"
    ];
    
    # Additional configuration for better accuracy
    extraConfig = ''
      # Improve clock accuracy
      rtcsync
      # Log clock changes over 0.5 seconds
      logchange 0.5
    '';
  };
  
  # Open firewall for NTP
  networking.firewall.allowedUDPPorts = [ 123 ];
}
```

### Complex Module Example

See the Firefox module implementation at `modules/applications/app-firefox.nix` for a more complex example.