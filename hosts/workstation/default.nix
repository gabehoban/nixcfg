# Custom desktop with AMD Ryzen 5 2600, 16GB RAM, AMD Rx 6700, and 1TB SSD + 2TB HDD.
{
  self,
  config,
  ...
}: {
  imports = [
    ./disko.nix
    ./home.nix
    ./secrets.nix
    ./stylix.nix
    ./realtek-r8125
    self.nixosModules.hardware-amd-cpu
    self.nixosModules.hardware-amd-gpu
    self.nixosModules.hardware-common
    self.nixosModules.locale-en-us
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "sd_mod"];
  boot.blacklistedKernelModules = ["r8169"];

  environment.variables.GDK_SCALE = "1.0";

  networking.hostName = "workstation";

  services = {
    nextjs-ollama-llm-ui.enable = true;

    ollama = {
      enable = true;
      acceleration = "rocm";

      loadModels = [
        "deepseek-r1:14b"
        "deepseek-r1:8b"
        "gemma2:9b"
        "llama3.1:8b"
        "llama3.2:3b"
      ];

      rocmOverrideGfx = "10.3.0";
    };
  };

  fileSystems."/games" = {
    device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_232758800485-part1";
    options = ["compress=zstd" "noatime"];
    fsType = "btrfs";
  };

  system.stateVersion = "24.05";
  time.timeZone = "America/New_York";

  myNixOS = {
    desktop = {
      gnome.enable = true;
    };

    profiles = {
      autoUpgrade.enable = true;
      base.enable = true;
      btrfs.enable = true;
      gaming.enable = true;
      workstation.enable = true;
    };

    programs = {
      firefox.enable = true;
      lanzaboote.enable = true;
      nix.enable = true;
      steam.enable = true;
    };

    services = {
      gdm = {
        enable = true;
        autologin = "gabehoban";
      };
    };
  };

  myUsers = {
    gabehoban = {
      enable = true;
      password = "$7$CU..../....OIPjbLfBFj5huEfCG5Mkv.$viRv8U/5R8PHZrpD2NpyDVTjKQ5aD5cfWhBPlTa0CCC";
    };
  };
}
