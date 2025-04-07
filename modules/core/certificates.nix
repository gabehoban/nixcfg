# modules/core/certificates.nix
#
# Automated certificate management with ACME/Let's Encrypt
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Automated certificate management with ACME
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@labrats.cc";

    # Use DNS challenge for wildcard certificates
    certs."labrats.cc" = {
      domain = "labrats.cc";
      extraDomainNames = [ "*.labrats.cc" ];
      dnsProvider = "cloudflare";
      credentialFiles = {
        "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.age.secrets.cloudflare-api-token.path;
      };
      dnsResolver = "1.1.1.1";
      dnsPropagationCheck = true;
      group = "ssl-cert"; # Group for services that need certificate access
    };
  };

  # Create certificate access group
  users.groups.ssl-cert = { };

  # TLS certificate paths
  age.secrets.cloudflare-api-token = {
    rekeyFile = ../../secrets/cloudflare-api-token.age;
    mode = "0400";
    owner = "acme";
  };

  # Ensure certificates directory exists and is persistent
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    "/var/lib/acme"
  ];

  # Systemd timer to check certificate expiration
  systemd.services.cert-expiration-check = {
    description = "Check certificate expiration dates";
    script = ''
      ${pkgs.openssl}/bin/openssl x509 -in /var/lib/acme/labrats.cc/cert.pem -checkend 604800 -noout
      if [ $? -ne 0 ]; then
        echo "Certificate for labrats.cc expires in less than 7 days!"
        exit 1
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "acme";
    };
  };

  systemd.timers.cert-expiration-check = {
    description = "Run certificate expiration check daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
