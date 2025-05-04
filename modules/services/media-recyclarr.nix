# modules/services/media-recyclarr.nix
#
# Recyclarr configuration syncing for *arr services
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Install recyclarr package
  environment.systemPackages = with pkgs; [
    recyclarr
  ];

  # Systemd service for scheduled syncing
  systemd.services.recyclarr = {
    description = "Recyclarr configuration sync service";
    after = [
      "network.target"
      "sonarr.service"
      "radarr.service"
    ];
    wants = [
      "sonarr.service"
      "radarr.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      WorkingDirectory = "/var/lib/recyclarr";
      EnvironmentFile = [
        config.age.secrets.sonarr-api-key.path
        config.age.secrets.radarr-api-key.path
      ];
      ExecStart = "${pkgs.recyclarr}/bin/recyclarr sync --config /var/lib/recyclarr/config/recyclarr.yml";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };

  # Systemd timer for scheduled syncing
  systemd.timers.recyclarr = {
    description = "Timer for Recyclarr configuration sync";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  # Create the configuration file
  systemd.services.recyclarr-setup = {
    description = "Set up Recyclarr configuration";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
            mkdir -p /var/lib/recyclarr/config

            cat > /var/lib/recyclarr/config/recyclarr.yml << 'EOF'
      # yaml-language-server: $schema=https://raw.githubusercontent.com/recyclarr/recyclarr/master/schemas/config-schema.json
      sonarr:
        sonarr:
          base_url: http://localhost:8989
          api_key: !env_var SONARR__AUTH__APIKEY
          delete_old_custom_formats: true
          replace_existing_custom_formats: true
          include:
            - template: sonarr-quality-definition-anime
            - template: sonarr-v4-quality-profile-anime
            - template: sonarr-v4-custom-formats-anime
            - template: sonarr-quality-definition-series
            - template: sonarr-v4-quality-profile-web-1080p
            - template: sonarr-v4-custom-formats-web-1080p
          quality_profiles:
            - name: WEB-1080p
          custom_formats:
            - trash_ids:
                - 026d5aadd1a6b4e550b134cb6c72b3ca # Uncensored
              assign_scores_to:
                - name: Remux-1080p - Anime
                  score: 0
            - trash_ids:
                - 418f50b10f1907201b6cfdf881f467b7
              assign_scores_to:
                - name: Remux-1080p - Anime
                  score: 0
            - trash_ids:
                - 32b367365729d530ca1c124a0b180c64 # Bad Dual Groups
                - 82d40da2bc6923f41e14394075dd4b03 # No-RlsGroup
                - e1a997ddb54e3ecbfe06341ad323c458 # Obfuscated
                - 06d66ab109d4d2eddb2794d21526d140 # Retags
              assign_scores_to:
                - name: WEB-1080p
            - trash_ids:
                - 1b3994c551cbb92a2c781af061f4ab44 # Scene
              assign_scores_to:
                - name: WEB-1080p
                  score: 0

      radarr:
        radarr:
          base_url: http://localhost:7878
          api_key: !env_var RADARR__AUTH__APIKEY
          delete_old_custom_formats: true
          replace_existing_custom_formats: true
          quality_profiles:
            - name: SQP-1 (2160p)
          include:
            - template: radarr-quality-definition-sqp-streaming
            - template: radarr-quality-profile-sqp-1-2160p-default
            - template: radarr-custom-formats-sqp-1-2160p
          custom_formats:
            - trash_ids:
                - 839bea857ed2c0a8e084f3cbdbd65ecb # x265 (no HDR/DV)
              assign_scores_to:
                - name: SQP-1 (2160p)
                  score: 0
            - trash_ids:
                - 7a0d1ad358fee9f5b074af3ef3f9d9ef # hallowed
                - b6832f586342ef70d9c128d40c07b872 # Bad Dual Groups
                - 90cedc1fea7ea5d11298bebd3d1d3223 # EVO (no WEBDL)
                - ae9b7c9ebde1f3bd336a8cbd1ec4c5e5 # No-RlsGroup
                - 7357cf5161efbf8c4d5d0c30b4815ee2 # Obfuscated
                - 5c44f52a8714fdd79bb4d98e2673be1f # Retags
                - f537cf427b64c38c8e36298f657e4828 # Scene
              assign_scores_to:
                - name: SQP-1 (2160p)
      EOF
    '';
  };

  # Data persistence for configuration
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    "/var/lib/recyclarr"
  ];
}
