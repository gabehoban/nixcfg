# modules/hardware/hw-gpu-amd.nix
#
# AMD GPU configuration and drivers
{
  pkgs,
  ...
}:
{
  #
  # Kernel and boot configuration
  #
  boot.initrd.kernelModules = [ "amdgpu" ];
  # Enable all power features and fix display timing issues
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff"
    "amdgpu.dcfeaturemask=1"
    "amdgpu.asyncdma=0"
  ];

  #
  # X11 and display drivers
  #
  services.xserver.videoDrivers = [ "amdgpu" ];

  #
  # ROCm environment setup
  #
  systemd.tmpfiles.rules =
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          clr
          rocblas
          rocm-comgr
          rocm-cmake
          rocm-device-libs
          rocm-runtime
          hipblas
          hipcc
          llvm.llvm
          llvm.clang
        ];
      };
    in
    [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    ];

  #
  # Graphics and OpenGL configuration
  #
  hardware.graphics = {
    enable = true;
    # Enable 32-bit support for compatibility
    enable32Bit = true;

    # Vulkan and OpenCL packages
    extraPackages = with pkgs; [
      # OpenCL implementation
      rocmPackages.clr.icd
      # AMD Vulkan driver
      amdvlk
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
    ];

    # 32-bit compatibility packages
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };

  #
  # ROCm support configuration
  #
  nixpkgs.config = {
    rocmSupport = true;
  };

  #
  # GPU monitoring and management tools
  #
  environment.systemPackages = with pkgs; [
    # AMD GPU control utility
    lact
    # ROCm information utility
    rocmPackages.rocminfo
    # ROCm system management interface
    rocmPackages.rocm-smi
  ];

  #
  # GPU control service
  #
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
