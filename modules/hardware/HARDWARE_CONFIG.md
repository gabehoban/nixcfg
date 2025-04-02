# Hardware Configuration Guide

This document provides guidance on configuring hardware-specific modules in this NixOS configuration.

## Hardware Module Structure

Hardware modules are organized by component type and vendor:

```
modules/hardware/
├── default.nix                # Core hardware detection and configuration
├── hw-cpu-amd.nix             # AMD CPU-specific configuration
├── hw-gpu-amd.nix             # AMD GPU-specific configuration
└── HARDWARE_CONFIG.md         # This documentation file
```

## Hardware Module Types

### CPU Modules

CPU modules (e.g., `hw-cpu-amd.nix`) typically configure:

1. **Microcode Updates**: Firmware updates for the CPU
   ```nix
   hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
   ```

2. **CPU Governor and Power Management**:
   ```nix
   boot.kernelParams = [ "amd_pstate=active" ];
   ```

3. **Temperature Monitoring and Fan Control**:
   ```nix
   boot.blacklistedKernelModules = [ "k10temp" ];
   boot.extraModulePackages = [ config.boot.kernelPackages.zenpower ];
   boot.kernelModules = [ "zenpower" ];
   ```

### GPU Modules

GPU modules (e.g., `hw-gpu-amd.nix`) typically configure:

1. **Graphics Drivers**:
   ```nix
   services.xserver.videoDrivers = [ "amdgpu" ];
   ```

2. **Hardware Acceleration**:
   ```nix
   hardware.opengl = {
     enable = true;
     driSupport = true;
     driSupport32Bit = true;
     extraPackages = with pkgs; [ amdvlk ];
     extraPackages32 = with pkgs.pkgsi686Linux; [ amdvlk ];
   };
   ```

3. **Kernel Parameters for GPU**:
   ```nix
   boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];
   ```

## Adding New Hardware Support

When adding support for new hardware:

1. **Identify Required Components**:
   - Determine what kernel modules, firmware, and drivers are needed
   - Check hardware compatibility with NixOS

2. **Create a New Hardware Module**:
   - Follow the naming convention: `hw-[component]-[vendor].nix`
   - Include appropriate documentation header
   - Group settings by functionality

3. **Test Thoroughly**:
   - Verify that the hardware functions correctly
   - Check for potential conflicts with other hardware modules
   - Test power management and performance

## Hardware Detection

The `default.nix` module in the hardware directory provides automatic hardware detection. It uses utilities like `nixos-hardware` to identify and configure common hardware platforms.

When hardware-specific configuration is complex, consider:

1. Creating a dedicated hardware profile in `profiles/hardware/`
2. Adding appropriate hardware modules to that profile
3. Documenting any special considerations or known issues

## Common Hardware Configuration Patterns

### Kernel Module Management

```nix
# Load specific kernel modules
boot.kernelModules = [ "module1" "module2" ];

# Prevent specific modules from loading
boot.blacklistedKernelModules = [ "problematic_module" ];

# Add out-of-tree kernel modules
boot.extraModulePackages = [ config.boot.kernelPackages.some-module ];
```

### Firmware and Microcode

```nix
# Enable redistributable firmware
hardware.enableRedistributableFirmware = true;

# CPU microcode updates
hardware.cpu.intel.updateMicrocode = true;
# or
hardware.cpu.amd.updateMicrocode = true;
```

### Specific Hardware Features

```nix
# GPU features
hardware.opengl = {
  enable = true;
  driSupport = true;
  driSupport32Bit = true;
};

# Special kernel parameters
boot.kernelParams = [ "parameter=value" ];
```

## Hardware-Specific Considerations

### AMD Hardware

- Use `amd_pstate=active` for modern AMD CPUs to enable the optimized power management driver
- Consider using `zenpower` for better temperature monitoring on Zen architecture
- For AMD GPUs, enable appropriate Vulkan support for gaming and GPU-accelerated applications

### Intel Hardware

- Always enable microcode updates for security
- Consider power management options like `intel_pstate` settings
- For Intel GPUs, ensure appropriate acceleration packages are installed

## Troubleshooting

When troubleshooting hardware issues:

1. Check kernel logs with `journalctl -k`
2. Verify loaded modules with `lsmod` 
3. Check hardware detection with `lspci` and `lsusb`
4. Test different kernel parameters by modifying GRUB boot entries temporarily
5. Consult the [NixOS Wiki](https://nixos.wiki/) for hardware-specific guidance