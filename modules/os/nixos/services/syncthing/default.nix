{
  config,
  lib,
  ...
}: {
  options.myNixOS.services.syncthing = {
    enable = lib.mkEnableOption "Syncthing file syncing service.";

    user = lib.mkOption {
      description = "User to run Syncthing as.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf config.myNixOS.services.syncthing.enable {
    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
    networking.firewall.allowedTCPPorts = [8384 22000];
    networking.firewall.allowedUDPPorts = [22000 21027];

    services.syncthing = let
      cfg = config.myNixOS.services.syncthing;
      devices = {
        "terra-cluster" = {id = "U6PP6R7-WGWO32D-AEWU4VC-K6RUKU7-SWTVYHX-QX4VBB5-HZOSFQM-TM6ZWQ3";};
        "workstation" = {id = "BDGEES4-FP6J45R-5RRS4OG-H5CFF4S-UFOCWZR-B4JLXXV-A4TJ3QJ-KUNAFQB";};
      };

      folders = {
        "Documents" = {
          path = "/home/${cfg.user}/documents";
          devices = ["terra-cluster" "workstation"];
        };
        "Pictures" = {
          path = "/home/${cfg.user}/pictures";
          devices = ["terra-cluster" "workstation"];
        };
        "Downloads" = {
          path = "/home/${cfg.user}/downloads";
          devices = ["terra-cluster" "workstation"];
        };
      };
    in {
      enable = true;
      dataDir = "/home/${cfg.user}";
      configDir = "/home/${cfg.user}/.config/syncthing";
      openDefaultPorts = true;
      user = cfg.user;

      settings = {
        options = {
          localAnnounceEnabled = true;
          relaysEnabled = true;
          urAccepted = -1;
        };
        inherit devices folders;
      };
    };
  };
}
