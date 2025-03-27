# Zed code editor configuration
{ pkgs, lib, ... }:
{
  #
  # System-wide dependencies
  #

  # Install Nix language server system-wide
  environment.systemPackages = with pkgs; [ nixd ];

  # Enable nix-ld for dynamic library loading (required by some Zed extensions)
  programs.nix-ld.enable = true;

  #
  # Zed configuration via home-manager
  #
  home-manager.users.gabehoban.programs.zed-editor = {
    enable = true;

    # Language servers and development tools
    extraPackages = with pkgs; [
      nixd # Nix language server
      nixfmt-rfc-style # Nix formatter
      rust-analyzer # Rust language server
      shellcheck # Shell script analyzer
      shfmt # Shell formatter
    ];

    # User preferences and settings
    userSettings = {
      # UI preferences
      font_family = "JetBrainsMono Nerd Font";
      line_height = "comfortable";
      autosave = "on_focus_change";

      # Disable GitHub Copilot
      features.copilot = false;

      # Nix language configuration
      nixd = {
        format_on_save = "on";
        formatting.command = [ "${lib.getExe pkgs.nixfmt-plus}" ];
        options.autoArchive = true;
      };

      # Language server preferences
      languages = {
        # Only use nixd for Nix files, disable nil language server
        Nix.language_servers = [
          "nixd"
          "!nil"
        ];
      };

      # Privacy settings - disable telemetry collection
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
    };
  };

  #
  # Persistence configuration
  #
  environment.persistence."/persist" = {
    users.gabehoban.directories = [
      # Store Zed configuration in persistent storage
      ".local/share/zed"
    ];
  };
}
