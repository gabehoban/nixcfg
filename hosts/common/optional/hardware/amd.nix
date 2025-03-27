# AMD GPU and CPU support configuration
{ pkgs, ... }:

{
  #
  # Kernel and driver configuration
  #

  # Load the amdgpu kernel module during early boot
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Configure X server to use amdgpu driver
  services.xserver.videoDrivers = [ "amdgpu" ];

  #
  # ROCm (Radeon Open Compute) support
  #

  # Create symlink for ROCm environments
  systemd.tmpfiles.rules =
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          # Core ROCm components
          clr
          rocblas
          rocm-comgr
          rocm-cmake
          rocm-device-libs
          rocm-runtime

          # HIP (Heterogeneous-Compute Interface for Portability)
          hipblas
          hipcc

          # LLVM components
          llvm.llvm
          llvm.clang
        ];
      };
    in
    [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    ];

  # Enable ROCm support globally
  nixpkgs.config = {
    rocmSupport = true;
  };

  #
  # Graphics configuration
  #

  # Hardware acceleration and graphics support
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd # OpenCL support
      amdvlk # Vulkan support
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk # 32-bit Vulkan support for compatibility
    ];
  };

  # Video acceleration configuration
  environment.sessionVariables = {
    "LIBVA_DRIVER_NAME" = "radeonsi"; # Use radeonsi for VA-API
  };

  #
  # AMD monitoring and control tools
  #

  # Install AMD management utilities
  environment.systemPackages = with pkgs; [
    lact # Linux AMD Control Tool
    rocmPackages.rocminfo # ROCm information utility
    rocmPackages.rocm-smi # ROCm System Management Interface
  ];

  # LACT daemon service for GPU control
  systemd.services.lact = {
    description = "AMDGPU Control Daemon";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
    };
    enable = true;
  };
}
