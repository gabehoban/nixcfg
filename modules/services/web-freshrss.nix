# modules/services/web-freshrss.nix
#
# FreshRSS feed reader service module
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./web-nginx.nix ];

  # Create a freshrss group if it doesn't exist
  users.groups.freshrss = { };

  # Add freshrss user to relevant groups
  users.users.freshrss = {
    isSystemUser = true;
    group = "freshrss";
  };

  # Secret for FreshRSS password - stored in a file
  age.secrets.freshrss-password = {
    rekeyFile = ../../secrets/freshrss-password.age;
    owner = "freshrss";
    group = "freshrss";
    mode = "0400";
  };

  # NixOS service configuration
  services.freshrss = {
    enable = true;

    # Use standard defaults
    defaultUser = "gabehoban";
    passwordFile = config.age.secrets.freshrss-password.path;

    # Configure URL
    baseUrl = "https://freshrss.labrats.cc";

    # Set virtualHost to a valid string value (required)
    virtualHost = "freshrss.labrats.cc";

    # Use SQLite for simplicity
    database.type = "sqlite";
  };

  # Configure nginx for FreshRSS
  services.nginx = {
    enable = true;
    virtualHosts."freshrss.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      # FreshRSS root directory
      root = "${pkgs.freshrss}/p";

      # PHP files handling - this regex is mandatory for the API
      locations."~ ^.+?\\.php(/.*)?$".extraConfig = ''
        fastcgi_split_path_info ^(.+\\.php)(/.*)$;
        # By default, the variable PATH_INFO is not set under PHP-FPM
        # But FreshRSS API greader.php needs it. This is important!
        set $path_info $fastcgi_path_info;
        fastcgi_param PATH_INFO $path_info;
        include ${pkgs.nginx}/conf/fastcgi_params;
        include ${pkgs.nginx}/conf/fastcgi.conf;
      '';

      # Default location handler
      locations."/" = {
        tryFiles = "$uri $uri/ index.php";
        index = "index.php index.html index.htm";
      };
    };
  };

  # Configure PHP-FPM pool
  services.phpfpm.pools.freshrss = {
    user = "freshrss";
    group = "freshrss";
    settings = {
      "listen.owner" = "nginx";
      "listen.group" = "nginx";
      "listen.mode" = lib.mkForce "0660";
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "catch_workers_output" = true;
    };
    phpEnv = {
      FRESHRSS_DATA_PATH = "/var/lib/freshrss";
    };
  };

  # Harden systemd service
  systemd.services.phpfpm-freshrss = {
    requires = [ "nginx.service" ];
    after = [ "nginx.service" ];
    serviceConfig.DynamicUser = lib.mkForce false;
  };

  # Ensure directories have proper permissions
  systemd.tmpfiles.rules = [
    "d /run/phpfpm 0777 root root - -"
  ];

  # Ensure nginx user can access the PHP-FPM socket
  users.users.nginx.extraGroups = [ "freshrss" ];

  # Persistence for FreshRSS data
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    {
      directory = "/var/lib/freshrss";
      user = "freshrss";
      group = "freshrss";
    }
  ];
}
