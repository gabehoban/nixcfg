# modules/services/media-plex.nix
#
# Plex Media Server configuration
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./web-nginx.nix ];

  services.plex = {
    enable = true;
    openFirewall = true;
    user = "plex";
    group = "media";

    extraPlugins = [
      (builtins.path {
        name = "Hama.bundle";
        path = pkgs.fetchFromGitHub {
          owner = "ZeroQI";
          repo = "Hama.bundle";
          rev = "fb6a5689359c6630c0fcfec58f8e3533497fd977";
          sha256 = "sha256-6xFYCg4wP1ZARKgOPxMZQlt4yHei9FwvqXI1fVHg1NA=";
        };
      })
    ];
    extraScanners = [
      (pkgs.fetchFromGitHub {
        owner = "ZeroQI";
        repo = "Absolute-Series-Scanner";
        rev = "43df2ee5de503221d9d4e96e399ca2eca8f19859";
        sha256 = "sha256-AvWUNkne9JfM6WrzoaLfOHu6NhZofS0vE+xjzxwLtzs=";
      })
    ];

    # Hardware acceleration - use render and video devices
    accelerationDevices = [
      "/dev/dri/renderD128"
      "/dev/dri/card0"
    ];
  };

  # Configure nginx for Plex
  services.nginx = {
    enable = true;
    virtualHosts."plex.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      # Plex-specific proxy settings
      locations."/" = {
        proxyPass = "http://127.0.0.1:32400";
        proxyWebsockets = true;

        # Plex websocket and streaming-specific headers
        extraConfig = ''
          proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
          proxy_set_header X-Plex-Device $http_x_plex_device;
          proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
          proxy_set_header X-Plex-Platform $http_x_plex_platform;
          proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
          proxy_set_header X-Plex-Product $http_x_plex_product;
          proxy_set_header X-Plex-Token $http_x_plex_token;
          proxy_set_header X-Plex-Version $http_x_plex_version;
          proxy_set_header X-Plex-Nocache $http_x_plex_nocache;
          proxy_set_header X-Plex-Provides $http_x_plex_provides;
          proxy_set_header X-Plex-Device-Vendor $http_x_plex_device_vendor;
          proxy_set_header X-Plex-Model $http_x_plex_model;

          # Buffering for smoother streaming
          proxy_buffering off;
        '';
      };
    };
  };

  # Add plex to video and render groups for hardware acceleration
  users.users.plex.extraGroups = [
    "video"
    "render"
    "media"
  ];

  # Make sure services start after NFS mounts are ready
  systemd.services.plex.requires = [ "export-media.mount" ];
  systemd.services.plex.after = [ "export-media.mount" ];

  # Data persistence
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    {
      directory = "/var/lib/plex";
      user = "plex";
      group = "media";
    }
  ];
}
