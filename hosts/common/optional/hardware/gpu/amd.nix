{ pkgs, ... }:
{
  boot.initrd.kernelModules = [ "amdgpu" ];

  services.xserver.videoDrivers = [ "amdgpu" ];

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

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      amdvlk
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };

  environment.sessionVariables = {
    "LIBVA_DRIVER_NAME" = "radeonsi";
  };

  nixpkgs.config = {
    rocmSupport = true;
  };

  environment.systemPackages = with pkgs; [
    lact
    rocmPackages.rocminfo
    rocmPackages.rocm-smi
  ];

  chaotic = {
    mesa-git = {
      enable = true;
      extraPackages = [ pkgs.amdvlk ];
      extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
    };
    nyx.cache.enable = true;
  };

  systemd.services.lact = {
    description = "AMDGPU Control Daemon";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
    };
    enable = true;
  };

  hardware.amdgpu.initrd.enable = true;
  programs.corectrl.gpuOverclock.ppfeaturemask = "0xffffffff";
}
