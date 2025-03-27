# AI services configuration (Ollama for local LLMs)
{ pkgs, ... }:
{
  services = {
    #
    # Ollama local LLM server configuration
    #
    ollama = {
      enable = false; # Disabled by default, enable as needed
      package = pkgs.ollama-rocm; # Use ROCm-enabled version for AMD GPUs
      host = "0.0.0.0"; # Listen on all interfaces
      acceleration = false; # Don't use hardware acceleration by default
    };
  };
}
