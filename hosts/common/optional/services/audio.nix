# Audio services configuration (PipeWire-based)
{ pkgs, ... }:
{
  #
  # Core audio services configuration
  #

  # Disable PulseAudio service (replaced by PipeWire)
  services.pulseaudio.enable = false;

  # Enable RealtimeKit for audio thread prioritization
  security.rtkit.enable = true;

  #
  # PipeWire configuration
  #
  services.pipewire = {
    enable = true;

    # ALSA compatibility layer
    alsa = {
      enable = true;
      support32Bit = true; # Support 32-bit applications
    };

    # PulseAudio compatibility layer
    pulse = {
      enable = true;
    };

    # Session and policy management
    wireplumber = {
      enable = true;
    };
  };

  #
  # Audio utilities
  #
  environment.systemPackages = with pkgs; [
    pulseaudio # PulseAudio utilities for compatibility
    pamixer # CLI volume control
    pavucontrol # GUI volume control
  ];
}
