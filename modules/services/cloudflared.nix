# modules/services/cloudflared.nix
#
# Cloudflared tunnel configuration for public service exposure
{
  config,
  lib,
  ...
}:

{
  # Secret for Cloudflare Tunnel
  age.secrets.cloudflare-tunnel-token = {
    rekeyFile = ../../secrets/cloudflare-tunnel-token.age;
    mode = "0400";
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "55e30de3-8b1f-472d-9fae-a17d56a9a7b2" = {
        credentialsFile = config.age.secrets.cloudflare-tunnel-token.path;

        # Default catch-all rule (required)
        default = "http_status:404";

        # Ingress rules
        ingress = {
          # Expose Attic binary cache
          "cache.labrats.cc" = {
            service = "http://localhost:8080";
            originRequest = {
              originServerName = "cache.labrats.cc";
              connectTimeout = "30s";
              noTLSVerify = false;
            };
          };
        };
      };
    };
  };

  # Data persistence
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    "/var/lib/cloudflared"
  ];
}
