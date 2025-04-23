# modules/services/graylog.nix
#
# Centralized logging setup with Graylog
# Configured for ingesting logs from homelab hosts
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./nginx.nix ];

  networking.firewall.allowedUDPPorts = [ 12201 ];

  users.groups = {
    graylog = { };
    mongodb = { };
    opensearch = { };
  };

  users.users = {
    graylog = {
      group = "graylog";
      home = "/var/empty";
      isSystemUser = true;
    };
    mongodb = {
      group = "mongodb";
      home = "/var/empty";
      isSystemUser = true;
    };
    opensearch = {
      group = "opensearch";
      home = "/var/empty";
      isSystemUser = true;
    };
  };

  age.secrets = {
    graylog-password = {
        rekeyFile = ../../secrets/graylog-password.age;
        owner = "graylog";
        group = "graylog";
        mode = "0440";
    };
    graylog-email-pass = {
        rekeyFile = ../../secrets/graylog-email-pass.age;
        owner = "graylog";
        group = "graylog";
        mode = "0440";
    };
  };

  systemd.services.graylog.preStart = ''
    hash=$(cat ${config.services.graylog.passwordSecret} | ${pkgs.perl}/bin/shasum -a 256 | ${pkgs.coreutils-full}/bin/cut -d " " -f1)
    email_pass=$(cat ${config.age.secrets.graylog-password.path})
    ${pkgs.gnused}/bin/sed "s/root_password_sha2.*/root_password_sha2 = $hash/g" $GRAYLOG_CONF > /etc/graylog.conf
    ${pkgs.gnused}/bin/sed "s/transport_email_auth_password.*/transport_email_auth_password = $email_pass/g" $GRAYLOG_CONF > /etc/graylog.conf
    export GRAYLOG_CONF="/etc/graylog.conf"
  '';

  services = {
    graylog = {
      enable = true;
      package = pkgs.graylog-6_0;
      rootUsername = "gabehoban";
      rootPasswordSha2 = ""; # will be set to correct value by preStart command
      passwordSecret = config.age.secrets.graylog-password.path;
      extraConfig = ''
        http_external_uri = https://logs.labrats.cc/
        java.net.preferIPv4Stack = true
        root_timezone = America/New_York
        root_email = homelab@labrats.cc
        allow_highlighting = true
        transport_email_enabled = true
        transport_email_hostname = ssl://smtp.titan.email
        transport_email_port = 465
        transport_email_use_tls = false
        transport_email_use_ssl = true
        transport_email_use_auth = true
        transport_email_from_email = homelab@labrats.cc
        transport_email_auth_username = homelab@labrats.cc
        transport_email_auth_password = ""
        transport_email_web_interface_url = https://logs.labrats.cc
        transport_email_socket_connection_timeout = 30s
        transport_email_socket_timeout = 30s
      '';
      elasticsearchHosts = [ "http://127.0.0.1:9200" ];
    };
    mongodb = {
      enable = true;
      package = pkgs.mongodb-ce;
      dbpath = "/var/lib/mongodb";
    };
    opensearch = {
      enable = true;
      settings = {
        "cluster.name" = "graylog";
        "search.max_aggregation_rewrite_filters" = "0";
      };
    };
  };
  systemd.services.graylog.serviceConfig.DynamicUser = lib.mkForce false;
  systemd.services.mongodb.serviceConfig.DynamicUser = lib.mkForce false;
  systemd.services.opensearch.serviceConfig.DynamicUser = lib.mkForce false;

  services.nginx = {
    enable = true;
    virtualHosts."logs.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";
      locations."/" = {
        proxyPass = "http://127.0.0.1:9000";
        proxyWebsockets = true;
      };
    };
  };

  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    {
      directory = "/var/lib/graylog";
      user = "graylog";
      group = "graylog";
    }
    {
      directory = "/var/lib/mongodb";
      user = "mongodb";
      group = "mongodb";
    }
    {
      directory = "/var/lib/opensearch";
      user = "opensearch";
      group = "opensearch";
    }
  ];
}
