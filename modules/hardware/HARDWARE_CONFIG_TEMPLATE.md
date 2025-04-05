# Hardware Module Configuration Template

This document provides a standardized template and best practices for creating hardware configuration modules in this NixOS configuration.

## Module Structure

All hardware modules should follow this basic structure:

```nix
# modules/hardware/hw-component-type.nix
#
# Component description and purpose
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.component;  # Adjust namespace as appropriate
in {
  # ==================== OPTIONS ====================
  options.hardware.component = {
    # Core option to enable/disable the component
    enable = mkEnableOption (mdDoc "component type with key functionality");
    
    # Component-specific options with detailed explanations
    specificOption = mkOption {
      type = types.str;  # Use appropriate type
      default = "default value";
      example = "example value";
      description = mdDoc ''
        Detailed description of the option.
        
        Include information about:
        - What the option does
        - Valid values or ranges
        - Side effects or interactions
      '';
    };
    
    # Additional options...
  };

  # ==================== IMPLEMENTATION ====================
  config = mkIf cfg.enable {
    # ────────────── Kernel Configuration ──────────────
    boot = {
      # Kernel modules required for this hardware
      kernelModules = [ "module1" "module2" ];
      
      # Additional kernel parameters
      kernelParams = [
        "param1=value1"
        "param2=value2"
      ];
      
      # Early-stage modules (if needed in initrd)
      initrd.kernelModules = [ "early_module" ];
      
      # Blacklisted modules (if needed)
      blacklistedKernelModules = [ "conflicting_module" ];
    };
    
    # ────────────── Hardware Services ──────────────
    hardware.firmware = with pkgs; [
      # Include any required firmware packages
      firmwareLinux-nonfree
      specific-firmware
    ];
    
    # ────────────── Device Configuration ──────────────
    services.udev.extraRules = ''
      # Rules for device permissions, symlinks, etc.
      SUBSYSTEM=="specific", ATTR{address}=="*", TAG+="systemd", ENV{SYSTEMD_WANTS}="service.service"
    '';
    
    # ────────────── Power Management ──────────────
    powerManagement = {
      # Power-specific settings
      cpuFreqGovernor = "powersave";  # Or appropriate governor
      
      # Powertop auto-tune settings
      powertop.enable = mkDefault true;
    };
    
    # ────────────── Environment Setup ──────────────
    environment = {
      # Variables needed for this hardware
      variables = {
        SPECIFIC_VAR = "value";
      };
      
      # Packages to install for management/monitoring
      systemPackages = with pkgs; [
        management-tool
        diagnostic-tool
      ];
    };
    
    # ────────────── Service Configuration ──────────────
    systemd.services.hardware-service = {
      description = "Hardware Management Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-udev-settle.service" ];
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.tool}/bin/tool --option";
        Restart = "on-failure";
      };
    };
    
    # ────────────── Dependencies and Assertions ──────────────
    assertions = [
      {
        assertion = config.another.service.enable;
        message = "This hardware module requires another.service to be enabled";
      }
    ];
  };
}
```

## Best Practices

### 1. Namespace Organization

Use consistent namespaces for hardware configurations:

- `hardware.cpu.*` - CPU-specific settings
- `hardware.gpu.*` - GPU-specific settings
- `hardware.wifi.*` - WiFi adapters
- `hardware.platform.*` - Platform-specific (Raspberry Pi, etc.)
- `hardware.peripheral.*` - External peripherals

### 2. Module Naming

Follow consistent naming patterns for hardware modules:

- `hw-type-vendor.nix` - For vendor-specific modules (e.g., `hw-cpu-amd.nix`)
- `hw-component.nix` - For generic components (e.g., `hw-bluetooth.nix`)

### 3. Documentation

Include comprehensive documentation in each module:

- Module header comment describing the purpose and hardware supported
- Option descriptions using `mdDoc` with examples and explanations
- Comments for non-obvious configurations

### 4. Dependencies

Clearly express dependencies on other modules:

- Use `assertions` to validate required dependencies
- Document required modules in the module header
- Use `mkIf` to conditionally enable features based on other options

### 5. Testing and Validation

Include validation for hardware configurations:

- Check for presence of required hardware
- Fall back gracefully when hardware is missing
- Include diagnostic tools in `environment.systemPackages`

### 6. Performance Optimization

Include hardware-specific optimizations:

- Set appropriate kernel parameters
- Configure optimal power management settings
- Include firmware and driver optimizations

## Example Implementations

### CPU Module Example

```nix
# modules/hardware/hw-cpu-amd.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.cpu.amd;
in {
  options.hardware.cpu.amd = {
    enable = mkEnableOption (mdDoc "AMD CPU optimizations");
    
    smt = mkOption {
      type = types.bool;
      default = true;
      description = mdDoc "Enable Simultaneous Multi-Threading (SMT)";
    };
    
    # Additional options...
  };
  
  config = mkIf cfg.enable {
    boot.kernelParams = [
      # CPU microcode and optimizations
      "amd_pstate=active"
      # Conditionally disable SMT if requested
      (mkIf (!cfg.smt) "smt=off")
    ];
    
    hardware.cpu.amd.updateMicrocode = true;
    
    environment.systemPackages = with pkgs; [
      # AMD-specific monitoring tools
      zenmonitor
      zenpower
      cpupower-gui
    ];
    
    # Additional CPU-specific configurations...
  };
}
```

### GPU Module Example

```nix
# modules/hardware/hw-gpu-nvidia.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.gpu.nvidia;
in {
  options.hardware.gpu.nvidia = {
    enable = mkEnableOption (mdDoc "NVIDIA GPU support");
    
    package = mkOption {
      type = types.package;
      default = pkgs.linuxPackages.nvidia_x11;
      description = mdDoc "NVIDIA driver package to use";
    };
    
    powerManagement.enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Enable NVIDIA power management features";
    };
    
    # Additional options...
  };
  
  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    
    boot.extraModulePackages = [ cfg.package ];
    
    # NVIDIA-specific power management
    boot.kernelParams = mkIf cfg.powerManagement.enable [
      "nvidia.NVreg_DynamicPowerManagement=0x02"
    ];
    
    # NVIDIA-specific environment variables
    environment.variables = {
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
    
    # Additional NVIDIA-specific configurations...
  };
}
```

## Testing Hardware Modules

### Basic Testing Procedure

1. Enable the module in a test configuration:
   ```nix
   { ... }:
   {
     hardware.component.enable = true;
   }
   ```

2. Check that hardware is detected:
   ```bash
   dmesg | grep component
   lspci | grep "Component Description"
   ```

3. Verify module parameters are applied:
   ```bash
   cat /sys/module/module_name/parameters/parameter
   ```

4. Test functionality:
   ```bash
   specific-test-command
   ```

### Automated Testing

Where possible, include automated tests for hardware modules:

```nix
# Check if hardware is present
devicePresent = builtins.pathExists "/sys/class/specific-class";

# Set conditional configuration based on hardware presence
config = mkIf (cfg.enable && devicePresent) { ... };
```