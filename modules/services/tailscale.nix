# modules/services/tailscale.nix
#
# Tailscale VPN service configuration with enhanced features
# Provides secure networking across machines with automatic connection and DNS support
{
  config,
  lib,
  pkgs,
  ...
}:

{
  age.secrets.tailscale-oath-env.rekeyFile = ../../secrets/tailscale-oath.age;

  # Core Tailscale service configuration
  services.tailscale = {
    enable = true;
    package = pkgs.tailscale;
    useRoutingFeatures = "client";
  };

  # Enable IP forwarding for both IPv4 and IPv6
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  # Firewall configuration
  networking.firewall = {
    # Trust the Tailscale interface
    trustedInterfaces = [ "tailscale0" ];
    # Use loose reverse path filtering for VPN compatibility
    checkReversePath = "loose";
    # Allow DNS for MagicDNS functionality
    allowedUDPPorts = [ 53 ];
  };

  # Ensure Tailscale connects automatically after network is available
  # and state directory is mounted (important with impermanence)
  systemd.services.tailscale = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    # Enhanced service properties for more reliable operation
    serviceConfig = {
      Restart = "always";
      RestartSec = "5";
    };
  };

  # Add automatic reconnect service that runs after Tailscale starts
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale network";
    # Make sure tailscale is running before trying to connect
    after = [
      "network-online.target"
      "tailscale.service"
    ];
    wants = [
      "network-online.target"
      "tailscale.service"
    ];
    wantedBy = [ "multi-user.target" ];

    # Set this service to start after the network and tailscale service are up
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      # For OAuth credentials, use EnvironmentFile to securely load credentials
      # Create a file with:
      #   TS_OAUTH_CLIENT_ID=your_client_id
      #   TS_OAUTH_CLIENT_SECRET=your_client_secret
      EnvironmentFile = config.age.secrets.tailscale-oath-env.path;
    };

    script = ''
      # Wait for tailscale to be fully initialized
      sleep 2

      # Check if we're already connected to the tailnet
      status="$(${pkgs.tailscale}/bin/tailscale status --json | ${pkgs.jq}/bin/jq -r .BackendState)"
      if [ "$status" = "Running" ]; then
        # Already connected, nothing to do
        exit 0
      fi

      # Prepare OAuth flags if credentials are available
      OAUTH_FLAGS="--auth-key=''${TS_OAUTH_CLIENT_SECRET}?ephemeral=false&preauthorized=true"

      # Not connected, attempt to connect with OAuth if available
      # The --reset flag ensures we're starting from a clean state
      ${pkgs.tailscale}/bin/tailscale up --reset --ssh --advertise-tags=tag:nix-hosts ''$OAUTH_FLAGS
    '';
  };

  # Add helpful Tailscale CLI tools and utilities
  environment.systemPackages = with pkgs; [
    tailscale # Core Tailscale client
    jq # Used for parsing tailscale status JSON
  ];

  # Add useful tailscale shell aliases
  programs.zsh.shellAliases = lib.mkIf (config.programs.zsh.enable or false) {
    ts-status = "tailscale status";
    ts-ip = "tailscale ip -4";
    ts-peers = "tailscale status --peers";
  };

  # Data persistence for stable node identity
  # This is critical for maintaining tailscale node identity across reboots
  impermanence.directories = lib.mkIf (config.impermanence.enable or false) [
    "/var/lib/tailscale"
    "/var/cache/tailscale"
  ];
}
