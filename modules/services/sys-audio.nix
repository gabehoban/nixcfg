# modules/services/sys-audio.nix
#
# Modern audio stack based on PipeWire
# Provides low-latency audio with compatibility layers for ALSA and PulseAudio
{
  pkgs,
  ...
}:
{
  #
  # Core audio services configuration
  #
  # Disable PulseAudio since PipeWire provides its own compatibility layer
  services.pulseaudio.enable = false;

  # Enable RealtimeKit for real-time thread scheduling without root privileges
  # This allows PipeWire to use RT scheduling for better audio performance
  security.rtkit.enable = true;

  #
  # PipeWire configuration
  #
  services.pipewire = {
    enable = true;

    # ALSA compatibility for applications that use ALSA directly
    alsa = {
      enable = true;
      support32Bit = true; # Needed for 32-bit games and applications
    };

    # PulseAudio compatibility for legacy applications
    pulse.enable = true;

    # WirePlumber handles session management and policy decisions
    # Preferred over the legacy session manager
    wireplumber.enable = true;
  };

  #
  # Audio utilities
  #
  environment.systemPackages = with pkgs; [
    pulseaudio # Includes pactl and other utilities for system integration
    pamixer # Simple CLI mixer for quick volume adjustments
    pavucontrol # GUI mixer for more detailed audio routing
  ];
}
