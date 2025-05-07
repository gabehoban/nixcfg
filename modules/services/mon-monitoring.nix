# modules/services/monitoring.nix
#
# Centralized monitoring setup with Prometheus and Grafana
# Configured for scraping metrics from homelab hosts
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./web-nginx.nix ];

  users.groups.grafana = { };
  users.users.grafana = {
    group = "grafana";
    isSystemUser = true;
  };

  users.groups.prometheus = { };
  users.users.prometheus = {
    group = "prometheus";
    isSystemUser = true;
  };

  users.groups.loki = { };
  users.users.loki = {
    group = "loki";
    isSystemUser = true;
  };

  # Prometheus server configuration
  services.prometheus = {
    enable = true;
    port = 9090;

    # Data retention (15 days)
    retentionTime = "15d";

    # Global configuration
    globalConfig = {
      scrape_interval = "15s";
      evaluation_interval = "15s";
    };

    # Enable node exporter for self-monitoring
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "systemd"
          "processes"
          "filesystem"
          "meminfo"
          "netdev"
          "diskstats"
          "cpu"
          "loadavg"
          "time"
        ];
        port = 9100;
        openFirewall = true;
      };
      systemd = {
        enable = true;
        port = 9558;
        openFirewall = true;
      };
    };

    # Alert configuration
    rules = [
      ''
        groups:
        - name: system
          rules:
          - alert: HighCPUUsage
            expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
            for: 10m
            labels:
              severity: warning
            annotations:
              summary: High CPU usage detected on {{ $labels.instance }}
              description: CPU usage is above 80% for more than 10 minutes
          - alert: LowDiskSpace
            expr: node_filesystem_free_bytes{fstype=~"ext4|xfs"} / node_filesystem_size_bytes < 0.1
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: Low disk space on {{ $labels.instance }}
              description: Less than 10% disk space remaining on {{ $labels.device }}
          - alert: HighMemoryUsage
            expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90
            for: 10m
            labels:
              severity: warning
            annotations:
              summary: High memory usage on {{ $labels.instance }}
              description: Memory usage is above 90% for more than 10 minutes
          - alert: ServiceDown
            expr: up == 0
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: Service down on {{ $labels.instance }}
              description: The monitored service on {{ $labels.instance }} has been down for more than 5 minutes
      ''
    ];

    # Scrape configurations
    scrapeConfigs = [
      # Scrape Prometheus itself
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "localhost:9090" ];
            labels = {
              instance = "nuc-titan";
            };
          }
        ];
      }

      # Scrape local node exporterf
      {
        job_name = "node-nuc-titan";
        static_configs = [
          {
            targets = [ "localhost:9100" ];
            labels = {
              instance = "nuc-titan";
            };
          }
        ];
      }

      # NUC hosts - using DNS service discovery
      {
        job_name = "node";
        dns_sd_configs = [
          {
            names = [
              "nuc-juno.local"
              "nuc-luna.local"
            ];
            type = "A";
            port = 9100;
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            regex = "([^:]+):.*";
            target_label = "instance";
            replacement = "$1";
          }
        ];
      }
    ];
  };
  systemd.services.prometheus.serviceConfig.DynamicUser = lib.mkForce false;

  age.secrets.alertmanager-email-pass = {
    rekeyFile = ../../secrets/alertmanager-email-pass.age;
    mode = "0400";
    owner = "prometheus";
    group = "prometheus";
  };

  # AlertManager configuration
  services.prometheus.alertmanager = {
    enable = true;
    port = 9093;
    environmentFile = config.age.secrets.alertmanager-email-pass.path;
    configuration = {
      global = {
        resolve_timeout = "5m";
        smtp_from = "homelab@labrats.cc";
        smtp_smarthost = "smtp.titan.email:587"; # Replace with your SMTP server
        smtp_auth_username = "homelab@labrats.cc";
        smtp_auth_password = "$SMTP_PASSWORD";
        smtp_require_tls = true;
      };
      route = {
        group_by = [
          "alertname"
          "instance"
        ];
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "12h";
        receiver = "default";
        routes = [
          {
            match = {
              severity = "critical";
            };
            receiver = "critical";
            repeat_interval = "1h";
          }
        ];
      };
      receivers = [
        {
          name = "default";
          email_configs = [
            {
              to = "admin@labrats.cc"; # Replace with your email
              send_resolved = true;
              html = ''
                {{ template "email.default.html" . }}
              '';
              text = ''
                {{ template "email.default.text" . }}
              '';
              headers = {
                Subject = ''[ALERT] {{ .Status | toUpper }} {{ .CommonLabels.alertname }}'';
              };
            }
          ];
        }
        {
          name = "critical";
          email_configs = [
            {
              to = "admin@labrats.cc"; # Replace with your email for critical alerts
              send_resolved = true;
              html = ''
                {{ template "email.default.html" . }}
              '';
              text = ''
                {{ template "email.default.text" . }}
              '';
              headers = {
                Subject = ''[CRITICAL] {{ .Status | toUpper }} {{ .CommonLabels.alertname }}'';
              };
            }
          ];
        }
      ];
      templates = [
        "/var/lib/alertmanager/templates/*.tmpl"
      ];
    };
  };
  systemd.services.alertmanager.serviceConfig.DynamicUser = lib.mkForce false;

  # Grafana configuration
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_port = 3000;
        root_url = "https://grafana.labrats.cc";
      };
      security = {
        admin_user = "admin";
        # admin_password is set via environment or generated on first run
      };
      analytics = {
        reporting_enabled = false;
        check_for_updates = false;
      };
      unified_alerting = {
        enabled = true;
        max_annotations_to_keep = 100;
      };
    };

    # Provision the Prometheus data source automatically
    provision = {
      enable = true;
      datasources = {
        settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://localhost:9090";
              isDefault = true;
            }
            {
              name = "Loki";
              type = "loki";
              url = "http://localhost:3100";
              isDefault = false;
            }
          ];
        };
      };
      # Add basic dashboards
      dashboards = {
        settings = {
          apiVersion = 1;
          providers = [
            {
              name = "default";
              options.path = "/var/lib/grafana/dashboards";
              orgId = 1;
              type = "file";
              disableDeletion = false;
              updateIntervalSeconds = 10;
              allowUiUpdates = false;
            }
          ];
        };
      };
    };
  };
  systemd.services.grafana.serviceConfig.DynamicUser = lib.mkForce false;

  # Loki configuration
  services.loki = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 3100;
        grpc_listen_port = 9096;
      };

      auth_enabled = false;

      common = {
        path_prefix = "/var/lib/loki";
        storage = {
          filesystem = {
            chunks_directory = "/var/lib/loki/chunks";
            rules_directory = "/var/lib/loki/rules";
          };
        };
        replication_factor = 1;
        ring = {
          kvstore = {
            store = "inmemory";
          };
        };
      };

      schema_config = {
        configs = [
          {
            from = "2020-05-15";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };

      ingester = {
        wal = {
          enabled = true;
          dir = "/var/lib/loki/wal";
        };
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore = {
              store = "inmemory";
            };
            replication_factor = 1;
          };
          final_sleep = "0s";
        };
        chunk_idle_period = "1h";
        max_chunk_age = "1h";
        chunk_target_size = 1048576;
        chunk_retain_period = "30s";
      };

      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
        ingestion_rate_mb = 10;
        ingestion_burst_size_mb = 20;
        retention_period = "720h"; # 30 days retention
        # Align with log retention - allow samples up to 30 days old
        max_global_streams_per_user = 5000;
        max_entries_limit_per_query = 5000;
      };

      compactor = {
        working_directory = "/var/lib/loki/compactor";
        compaction_interval = "10m";
        retention_enabled = true;
        retention_delete_delay = "2h";
        retention_delete_worker_count = 150;
        delete_request_store = "filesystem";
      };
    };
  };
  systemd.services.loki.serviceConfig.DynamicUser = lib.mkForce false;

  # Promtail configuration for Mikrotik syslog
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 9080;
        grpc_listen_port = 0;
      };

      positions = {
        filename = "/var/lib/promtail/positions.yaml";
      };

      clients = [
        {
          url = "http://localhost:3100/loki/api/v1/push";
        }
      ];

      scrape_configs = [
        {
          job_name = "syslog";
          syslog = {
            listen_address = "0.0.0.0:514";
            listen_protocol = "udp"; # Mikrotik sends syslog over UDP by default
            syslog_format = "rfc3164"; # Mikrotik uses RFC 3164 format
            idle_timeout = "60s";
            label_structured_data = false; # RFC 3164 doesn't have structured data
            labels = {
              job = "mikrotik";
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__syslog_message_hostname" ];
              target_label = "host";
            }
            {
              source_labels = [ "__syslog_message_app_name" ];
              target_label = "app";
            }
            {
              source_labels = [ "__syslog_message_severity" ];
              target_label = "level";
            }
            {
              source_labels = [ "__syslog_message_facility" ];
              target_label = "facility";
            }
          ];
        }
        # Scrape local journal logs
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
            {
              source_labels = [ "__journal__hostname" ];
              target_label = "host";
            }
          ];
        }
      ];
    };
  };
  systemd.services.promtail.serviceConfig = {
    User = lib.mkForce "root";
    DynamicUser = lib.mkForce false;
    AmbientCapabilities = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
    CapabilityBoundingSet = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
    NoNewPrivileges = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
  };

  # Required packages
  environment.systemPackages = with pkgs; [
    prometheus
    prometheus-node-exporter
    grafana
    loki
    promtail
    pwgen
    curl
    jq
    sqlite
  ];

  # Open firewall ports for the services
  networking.firewall.allowedTCPPorts = [
    9090 # Prometheus
    3000 # Grafana
    9100 # Node exporter
    3100 # Loki
    9080 # Promtail
    9113 # Nginx exporter
    9558 # Systemd exporter
    9093 # AlertManager
    514 # Syslog TCP
  ];

  # Open UDP port for syslog
  networking.firewall.allowedUDPPorts = [
    514 # Syslog
  ];

  # Setup default dashboards
  systemd.services.grafana-dashboards = {
    description = "Add default Grafana dashboards";
    wantedBy = [ "multi-user.target" ];
    after = [
      "grafana.service"
      "network-online.target"
    ];
    requires = [ "grafana.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "grafana";
      Group = "grafana";
      RemainAfterExit = true;
      TimeoutStartSec = "120s";
    };
    script = ''
      # Wait for Grafana to be ready
      for i in {1..30}; do
        if ${pkgs.curl}/bin/curl -s http://localhost:3000/api/health | grep -q "ok"; then
          echo "Grafana is ready"
          break
        fi
        echo "Waiting for Grafana to be ready..."
        sleep 2
      done

      # Create dashboard directory
      mkdir -p /var/lib/grafana/dashboards

      # First, clean up old dashboards that are no longer managed
      # Try multiple methods to find Grafana admin password
      GRAFANA_ADMIN_PASS=""

      # Check for password file
      if [ -f /var/lib/grafana/.grafana-admin-password ]; then
        GRAFANA_ADMIN_PASS=$(cat /var/lib/grafana/.grafana-admin-password)
        echo "Found admin password in password file"
      fi

      # Check if we should skip cleanup altogether
      SKIP_CLEANUP=false
      if [ "$SKIP_CLEANUP" = "true" ]; then
        echo "Skipping dashboard cleanup as requested..."
      else
        echo "Attempting to remove unmanaged dashboards..."

        # Get list of dashboards currently in Grafana
        HTTP_RESPONSE=$(${pkgs.curl}/bin/curl -s -w "\n%{http_code}" -u "admin:$GRAFANA_ADMIN_PASS" "http://localhost:3000/api/search?type=dash-db")
        HTTP_CODE=$(echo "$HTTP_RESPONSE" | tail -n1)
        DASHBOARD_RESPONSE=$(echo "$HTTP_RESPONSE" | sed '$d')

        # Check HTTP status code
        if [ "$HTTP_CODE" != "200" ]; then
          echo "Error: Grafana API returned HTTP status code $HTTP_CODE"
          echo "Response: $DASHBOARD_RESPONSE"
          echo "Skipping dashboard cleanup..."
          echo "Note: This is not critical. Proceeding with dashboard installation..."
        elif ! echo "$DASHBOARD_RESPONSE" | ${pkgs.jq}/bin/jq '.' >/dev/null 2>&1; then
          echo "Error: Grafana API returned invalid JSON or an error message:"
          echo "$DASHBOARD_RESPONSE"
          echo "Skipping dashboard cleanup..."
          echo "Note: This is not critical. Proceeding with dashboard installation..."
        else
          # Check if response is empty array
          if [ "$(echo "$DASHBOARD_RESPONSE" | ${pkgs.jq}/bin/jq 'length')" -eq 0 ]; then
            echo "No dashboards found in Grafana."
          else
            # Parse valid response
            echo "$DASHBOARD_RESPONSE" | ${pkgs.jq}/bin/jq -r '.[] | select(.uid != "") | .uid' | while read -r uid; do

              # Skip built-in dashboards
              if [[ "$uid" == "home" ]] || [[ "$uid" == "alerting" ]]; then
                continue
              fi

              # Check if this dashboard is managed by our configuration
              case "$uid" in
                "mikrotik-firewall-v2"|"mikrotik-wan-lan-v3"|"mikrotik-security"|"mikrotik-services"|"mikrotik-time-v2")
                  echo "Keeping managed dashboard: $uid"
                  ;;
                "mikrotik-wan-lan"|"mikrotik-wan-lan-v2"|"mikrotik-time")
                  echo "Removing old dashboard with non-current UID: $uid"
                  ${pkgs.curl}/bin/curl -s -X DELETE -u "admin:$GRAFANA_ADMIN_PASS" \
                    "http://localhost:3000/api/dashboards/uid/$uid"
                  ;;
                mikrotik-*)
                  echo "Removing old Mikrotik dashboard: $uid"
                  ${pkgs.curl}/bin/curl -s -X DELETE -u "admin:$GRAFANA_ADMIN_PASS" \
                    "http://localhost:3000/api/dashboards/uid/$uid"
                  ;;
                *)
                  # Keep non-Mikrotik dashboards (like node-exporter)
                  echo "Keeping dashboard: $uid"
                  ;;
              esac
            done
          fi
        fi
      fi

      # Download Node Exporter dashboard
      ${pkgs.curl}/bin/curl -L -o /var/lib/grafana/dashboards/node-exporter.json https://grafana.com/api/dashboards/1860/revisions/27/download

      # Create Mikrotik Firewall Logs V2 dashboard
      cat > /var/lib/grafana/dashboards/mikrotik-firewall-v2.json << 'EOF'
      ${builtins.readFile ../../dashboards/mikrotik-firewall-v2.json}
      EOF

      # Create Mikrotik WAN vs LAN Analysis dashboard
      cat > /var/lib/grafana/dashboards/mikrotik-wan-lan-analysis.json << 'EOF'
      ${builtins.readFile ../../dashboards/mikrotik-wan-lan-analysis-v3.json}
      EOF

      # Create Mikrotik Security Threats dashboard
      cat > /var/lib/grafana/dashboards/mikrotik-security-threats.json << 'EOF'
      ${builtins.readFile ../../dashboards/mikrotik-security-threats.json}
      EOF

      # Create Mikrotik Service Analysis dashboard
      cat > /var/lib/grafana/dashboards/mikrotik-service-analysis.json << 'EOF'
      ${builtins.readFile ../../dashboards/mikrotik-service-analysis.json}
      EOF

      # Create Mikrotik Time-based Analysis dashboard
      cat > /var/lib/grafana/dashboards/mikrotik-time-analysis.json << 'EOF'
      ${builtins.readFile ../../dashboards/mikrotik-time-analysis-v2.json}
      EOF

      # Set proper permissions
      chmod 644 /var/lib/grafana/dashboards/*.json
    '';
  };

  services.nginx = {
    enable = true;
    virtualHosts."grafana.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      locations."/" = {
        proxyPass = "http://localhost:3000";
        proxyWebsockets = true;
      };
    };
    virtualHosts."prometheus.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      locations."/" = {
        proxyPass = "http://localhost:9090";
        proxyWebsockets = true;
      };
    };
    virtualHosts."loki.labrats.cc" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/labrats.cc/cert.pem";
      sslCertificateKey = "/var/lib/acme/labrats.cc/key.pem";
      sslTrustedCertificate = "/var/lib/acme/labrats.cc/chain.pem";

      locations."/" = {
        proxyPass = "http://localhost:3100";
        proxyWebsockets = true;
      };
    };
  };

  # Create persistable directories
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    {
      directory = "/var/lib/grafana";
      user = "grafana";
      group = "grafana";
    }
    {
      directory = "/var/lib/prometheus2";
      user = "prometheus";
      group = "prometheus";
    }
    {
      directory = "/var/lib/loki";
      user = "loki";
      group = "loki";
    }
    {
      directory = "/var/lib/promtail";
      user = "promtail";
      group = "promtail";
    }
    {
      directory = "/var/lib/alertmanager";
      user = "prometheus";
      group = "prometheus";
    }
  ];
}
