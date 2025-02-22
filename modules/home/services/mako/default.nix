{
  config,
  lib,
  pkgs,
  ...
}: {
  options.myHome.services.mako.enable = lib.mkEnableOption "mako notification daemon";

  config = lib.mkIf config.myHome.services.mako.enable {
    services.mako = {
      actions = true;
      anchor = "bottom-right";
      borderRadius = 10;
      borderSize = 4;
      defaultTimeout = 10000;
      enable = true;
      groupBy = "app-name";
      height = 300;
      iconPath = "${pkgs.papirus-icon-theme}/share/icons/Papirus/";
      icons = true;
      layer = "top";
      margin = "20,0";
      padding = "15";
      sort = "+time";
      width = 400;

      extraConfig = ''
        on-notify=exec mpv ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/message.oga
        outer-margin=20

        [mode=do-not-disturb]
        invisible=1
      '';
    };

    systemd.user.services.mako = {
      Unit = {
        After = "graphical-session.target";
        BindsTo = lib.optional (config.wayland.windowManager.hyprland.enable) "hyprland-session.target";
        Description = "Lightweight Wayland notification daemon";
        Documentation = "man:mako(1)";
        PartOf = "graphical-session.target";
      };

      Service = {
        BusName = "org.freedesktop.Notifications";
        Environment = ["PATH=${lib.makeBinPath [pkgs.bash pkgs.mpv]}"];
        ExecReload = ''${lib.getExe' pkgs.mako "makoctl"} reload'';
        ExecStart = "${lib.getExe pkgs.mako}";
        Restart = lib.mkForce "no";
        Type = "dbus";
      };

      Install.WantedBy = lib.optional (config.wayland.windowManager.hyprland.enable) "hyprland-session.target";
    };
  };
}
