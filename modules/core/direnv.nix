# modules/core/direnv.nix
#
# direnv configuration to allow automatic environment switching
_: {
  # System-wide direnv setup
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Home Manager configuration
  home-manager.users.gabehoban = {
    # Install and configure direnv
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;

      # Enable logging
      stdlib = ''
        # Enables logging of direnv operations
        : ''${DIRENV_LOG_FORMAT:="[%s] %s"}
      '';
    };

    # Enable ZSH integration with direnv
    programs.zsh.initExtra = ''
      # Direnv hook for zsh
      eval "$(direnv hook zsh)"
    '';
  };
}
