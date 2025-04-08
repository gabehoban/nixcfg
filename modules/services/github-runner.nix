# modules/services/cloudflared.nix
#
# Cloudflared tunnel configuration for public service exposure
{
  config,
  pkgs,
  ...
}:

{
  # Secret for Cloudflare Tunnel
  age.secrets.github-runner-token = {
    rekeyFile = ../../secrets/github-runner-token.age;
    mode = "0400";
    owner = "github-runner";
    group = "github-runner";
  };

  users.users.github-runner = {
    description = "Github runner";
    isSystemUser = true;
    group = "github-runner";
  };
  users.groups.github-runner = { };

  virtualisation.docker.enable = true;

  services.github-runners.nixos-runner = {
    enable = true;
    url = "https://github.com/gabehoban/nixcfg";
    user = "github-runner";
    group = "github-runner";
    tokenFile = config.age.secrets.github-runner-token.path;
    extraPackages = with pkgs; [
      docker
      nix
      git
    ];
    extraLabels = [
      "nixos"
      "docker"
    ];
  };
}
