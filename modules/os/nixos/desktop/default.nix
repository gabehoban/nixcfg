{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./gnome
  ];

  options.myNixOS.desktop.enable = lib.mkOption {
    default = config.myNixOS.desktop.gnome.enable or config.myNixOS.desktop.hyprland.enable or config.myNixOS.desktop.kde.enable;
    description = "Desktop environment configuration.";
    type = lib.types.bool;
  };

  config = lib.mkIf config.myNixOS.desktop.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "1password-gui"
        "1password"
      ];

    boot = {
      consoleLogLevel = 0;
      initrd.verbose = false;
      plymouth.enable = true;
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    home-manager.sharedModules = [
      {
        config.myHome.desktop.enable = true;
      }
    ];

    programs.system-config-printer.enable = true;
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = ["gabehoban"];
    };

    services = {
      gnome.gnome-keyring.enable = true;
      gvfs.enable = true;
      libinput.enable = true;

      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
      };

      printing.enable = true;

      pulseaudio = {
        package = pkgs.pulseaudioFull;
        extraConfig = ''
          load-module module-bluetooth-discover
          load-module module-bluetooth-policy
          load-module module-switch-on-connect
        '';
        support32Bit = true;
      };

      system-config-printer.enable = true;

      xserver = {
        enable = true;
        excludePackages = with pkgs; [xterm];
      };
    };
  };
}
