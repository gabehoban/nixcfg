# modules/services/graylog.nix
#
# Centralized logging setup with Graylog
# Configured for ingesting logs from homelab hosts
#
# This module creates a complete Graylog deployment with:
# - Runtime-only secret handling for secure operation
# - OpenSearch for data storage
# - MongoDB for metadata storage
# - Proper permissions and service configuration
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
    graylog-secret = {
        rekeyFile = ../../secrets/graylog-secret.age;
        owner = "graylog";
        group = "graylog";
        mode = "0440";
    };
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

  systemd.tmpfiles.rules = [
    "d /var/log/opensearch 0750 opensearch opensearch - -"
    "d /var/lib/graylog/server 0750 graylog graylog - -"
    "d /var/lib/graylog/plugins 0750 graylog graylog - -"
    "d /var/lib/graylog/journal 0750 graylog graylog - -"
  ];
  systemd.services.graylog = {
    after = [ "mongodb.service" "opensearch.service" ];
    requires = [ "mongodb.service" "opensearch.service" ];

    # Make the service config secure
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "30s";
      RuntimeDirectory = "graylog";
      RuntimeDirectoryMode = "0750";
      User = "graylog";
      Group = "graylog";
      PrivateTmp = true;
      DynamicUser = lib.mkForce false;
      WorkingDirectory = "/var/lib/graylog";
    };

    # Set the environment to use our runtime config and ensure JVM has the right settings
    environment = {
      GRAYLOG_CONF = lib.mkForce "/run/graylog/graylog.conf";
      JAVA_HOME = "${pkgs.jre_headless}";
      GRAYLOG_SERVER_JAVA_OPTS = "-Xms1g -Xmx2g -XX:+UseG1GC -server";
    };

    preStart = ''
        secret=$(cat ${config.age.secrets.graylog-secret.path})
        password=$(cat ${config.age.secrets.graylog-password.path})
        email_pass=$(cat ${config.age.secrets.graylog-email-pass.path})

        # Install plugins if any are configured
        ${lib.optionalString (config.services.graylog.plugins != []) ''
        # Create plugins directory
        mkdir -p /var/lib/graylog/plugins

        # Remove old plugins to avoid version conflicts
        rm -f /var/lib/graylog/plugins/*.jar

        # Copy new plugins
        ${lib.concatMapStrings (plugin: ''
          cp -f ${plugin}/bin/*.jar /var/lib/graylog/plugins/
          chmod 644 /var/lib/graylog/plugins/*.jar
        '') config.services.graylog.plugins}

        # Fix ownership
        chown -R graylog:graylog /var/lib/graylog/plugins
        ''}

        # Create variable for better readability
        EXTERNAL_URI="https://logs.labrats.cc/"
        EMAIL_HOST="ssl://smtp.titan.email"
        EMAIL_FROM="homelab@labrats.cc"
        EMAIL_USER="homelab@labrats.cc"

        # Create config file directly in the runtime directory
        # Since there's no example config file in the package, we'll create one from scratch
        cat > /run/graylog/graylog.conf <<EOF
# Graylog server configuration
is_master = ${lib.boolToString config.services.graylog.isMaster}
node_id_file = /var/lib/graylog/server/node-id
password_secret = $secret
root_username = ${config.services.graylog.rootUsername}
root_password_sha2 = $password
elasticsearch_hosts = ${builtins.elemAt config.services.graylog.elasticsearchHosts 0}
message_journal_dir = ${config.services.graylog.messageJournalDir}
mongodb_uri = ${config.services.graylog.mongodbUri}
plugin_dir = /var/lib/graylog/plugins
data_dir = /var/lib/graylog

# OpenSearch specific configuration
elasticsearch_backend = opensearch

# Email configuration
http_external_uri = $EXTERNAL_URI
java.net.preferIPv4Stack = true
root_timezone = America/New_York
root_email = $EMAIL_FROM
allow_highlighting = true
transport_email_enabled = true
transport_email_hostname = $EMAIL_HOST
transport_email_port = 465
transport_email_use_tls = false
transport_email_use_ssl = true
transport_email_use_auth = true
transport_email_from_email = $EMAIL_FROM
transport_email_auth_username = $EMAIL_USER
transport_email_auth_password = "$email_pass"
transport_email_web_interface_url = $EXTERNAL_URI
transport_email_socket_connection_timeout = 30s
transport_email_socket_timeout = 30s
EOF

        # Set appropriate permissions
        chmod 640 /run/graylog/graylog.conf
        chown graylog:graylog /run/graylog/graylog.conf
    '';
  };

  services = {
    graylog = {
      enable = true;
      package = pkgs.graylog-6_0;
      rootUsername = "gabehoban";
      # Empty strings since we'll handle these in preStart
      rootPasswordSha2 = "";
      passwordSecret = "";
      # Keep empty as we'll handle the configuration in preStart
      extraConfig = "";
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
        "node.name" = "graylog-node";
        "discovery.type" = "single-node";
        "path.data" = "/var/lib/opensearch";
        "path.logs" = "/var/log/opensearch";
        "http.port" = 9200;
        "plugins.security.disabled" = true;
      };
    };
  };
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
    {
      directory = "/var/log/opensearch";
      user = "opensearch";
      group = "opensearch";
    }
  ];
}
