# modules/services/dev-forgejo.nix
#
# Forgejo Git service configuration
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Import nginx module as it's required for proper web access
  imports = [ ./web-nginx.nix ];

  # Create forgejo user
  users.groups.forgejo = { };
  users.users.forgejo = {
    isSystemUser = true;
    group = "forgejo";
  };

  # Secret for admin password (used during initial setup)
  age.secrets.forgejo-admin-password = {
    rekeyFile = ../../secrets/forgejo-admin-password.age;
    owner = "forgejo";
    group = "forgejo";
    mode = "0400";
  };

  # Enable and configure Forgejo service
  services.forgejo = {
    enable = true;
    user = "forgejo";
    group = "forgejo";

    # Use SQLite3 for the database
    database.type = "sqlite3";

    # Specify data location for repositories and database
    stateDir = "/var/lib/forgejo";

    # Enable support for Git Large File Storage
    lfs.enable = true;

    # Basic service configuration
    settings = {
      server = {
        DOMAIN = "git.labrats.cc";
        ROOT_URL = "https://git.labrats.cc/";
        HTTP_PORT = 5400;

        SSH_DOMAIN = "git.labrats.cc";
        START_SSH_SERVER = true;
        SSH_PORT = 2222;
      };

      # Disable registration after initial admin setup
      service.DISABLE_REGISTRATION = true;

      # Configure repository settings
      repository = {
        DEFAULT_BRANCH = "main";
        DEFAULT_PRIVATE = "private";
        ENABLE_PUSH_CREATE_USER = true;
        ENABLE_PUSH_CREATE_ORG = true;
      };

      # Security settings
      security = {
        INSTALL_LOCK = true;
      };
    };
  };

  # Create admin user on initial start
  systemd.services.forgejo.preStart =
    let
      adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
      pwdFile = config.age.secrets.forgejo-admin-password.path;
      user = "gabehoban";
    in
    ''
      ${adminCmd} create --admin --email "gabe@hoban.io" --username ${user} --password "$(tr -d '\n' < ${pwdFile})" || true
      # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${pwdFile})" || true
    '';
  systemd.services.forgejo.serviceConfig.DynamicUser = lib.mkForce false;

  # Configure nginx for Forgejo
  services.nginx = {
    enable = true;
    virtualHosts."git.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      # Configure proxy pass to the Forgejo service
      locations."/".proxyPass =
        "http://localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}";

      # Allow large uploads for Git repos
      extraConfig = ''
        client_max_body_size 512M;
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [
    2222 # Forgejo SSH port
  ];

  # Persistence for Forgejo data
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    {
      directory = "/var/lib/forgejo";
      user = "forgejo";
      group = "forgejo";
    }
  ];
}
