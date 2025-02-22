{pkgs, ...}: {
  config = {
    hardware = {
      amdgpu = {
        initrd.enable = true;

        amdvlk = {
          enable = true;
          support32Bit.enable = true;
        };

        opencl.enable = true;
      };

      graphics.enable = true;
    };
    systemd.tmpfiles.rules = [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];
  };
}
