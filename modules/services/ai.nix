# modules/services/ai.nix
#
# AI services configuration (Ollama for local LLMs)
{
  pkgs,
  ...
}:
{
  #
  # Ollama local LLM service configuration
  #
  services.ollama = {
    # Disabled by default, enable as needed
    enable = false;

    # Use ROCm-enabled version for AMD GPUs
    package = pkgs.ollama-rocm;

    # Listen on all interfaces
    host = "0.0.0.0";

    # Don't use hardware acceleration by default
    acceleration = false;
  };

  #
  # System packages for AI and ML development
  #
  environment.systemPackages = with pkgs; [
    # Command-line interface for Ollama
    # Only installed when service is enabled
    ollama-rocm
  ];

  #
  # Persistence configuration
  #
  environment.persistence."/persist" = {
    directories = [
      # Persist Ollama models across reboots
      "/var/lib/ollama"
    ];
  };
}
