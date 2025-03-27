# Zsh shell configuration
# Configures the Z shell with modern features and plugins
{ pkgs, ... }:
{
  # Set zsh as the default shell for all users
  users.defaultUserShell = pkgs.zsh;

  # Include ~/bin and ~/.local/bin in PATH
  environment.localBinInPath = true;

  # Enable zsh for the system
  programs.zsh.enable = true;

  # User-specific configuration via home-manager
  home-manager.users.gabehoban = {
    # Additional packages specific to shell environment
    home.packages = [ pkgs.sqlite-interactive ];

    # Zsh configuration
    programs.zsh = {
      enable = true;
      dotDir = ".config/zsh"; # XDG compliant zsh config path

      # History settings
      history = {
        path = "\${XDG_DATA_HOME-$HOME/.local/share}/zsh/history"; # XDG compliant history path
        save = 1000500; # Number of lines to save
        size = 1000000; # Number of lines to keep in memory
      };

      # Main shell configuration
      initExtra = ''
        # =====================
        # Widget and hook setup
        # =====================
        autoload -U add-zle-hook-widget

        # Fix autosuggestions with history widgets
        # See https://github.com/zsh-users/zsh-autosuggestions/issues/619
        ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(history-beginning-search-backward-end history-beginning-search-forward-end)

        # =======================
        # Completion style config
        # =======================

        # Git checkout completion: don't sort (show in order of recency)
        zstyle ':completion:*:git-checkout:*' sort false

        # Enable group descriptions in completions
        zstyle ':completion:*:descriptions' format '[%d]'

        # Always show completion menu
        zstyle ':completion:*' menu yes

        # Preview directories when completing cd
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -lAhF --group-directories-first --show-control-chars --quoting-style=escape --color=always $realpath'
        zstyle ':fzf-tab:complete:cd:*' popup-pad 20 0

        # Don't insert tabs when there's no completion available
        zstyle ':completion:*' insert-tab false

        # Don't automatically insert the first match even if unique
        zstyle ':completion:*' insert-unambiguous false

        # Show directories first in completion lists
        zstyle ':completion:*' list-dirs-first true

        # Show original input for expansion/approximate completions
        zstyle ':completion:*' original true

        # Treat multiple slashes as a single / (like UNIX does)
        zstyle ':completion:*' squeeze-slashes true

        # Show detailed completion info
        zstyle ':completion:*' verbose true

        # Enable ".." as a completion option
        zstyle ':completion:*' special-dirs ..

        # Case-insensitive completion
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

        # ================
        # History settings
        # ================

        # Ignore patterns for history
        HISTORY_IGNORE_REGEX='^(.|. |..|.. |rm .*|rmd .*|git fixup.*|git unstash|git stash.*|git checkout -f.*)$'
        function zshaddhistory() {
        	emulate -L zsh
        	[[ ! $1 =~ "$HISTORY_IGNORE_REGEX" ]]
        }

        # =============
        # Shell options
        # =============

        # Globbing and matching
        setopt nomatch        # Error on patterns with no matches
        setopt noextendedglob # No extended globbing
        setopt noglobdots     # Don't match dotfiles with *
        setopt hash_list_all  # Hash command path on completion

        # Directory navigation
        setopt auto_cd           # Change directory by typing path
        setopt auto_pushd        # Push dirs onto directory stack
        setopt pushd_ignore_dups # Don't duplicate dirs in stack

        # Process handling
        setopt long_list_jobs # Show PID when suspending jobs
        setopt nohup          # Don't send SIGHUP on shell exit
        setopt notify         # Report job status immediately

        # Shell interface
        setopt interactive_comments # Allow comments in interactive shells
        setopt nobeep             # Don't beep

        # Completion options
        setopt nocorrect        # Don't correct commands
        setopt complete_in_word # Allow completion within words
        setopt no_correct_all   # Don't autocorrect
        setopt auto_list        # List choices on ambiguous tab
        setopt auto_menu        # Use completion menu when requested
        setopt always_to_end    # Move cursor to end after completion
      '';

      # Early initialization (runs before plugins)
      initExtraFirst = ''
        # Set SQLite history database path
        HISTDB_FILE=''${XDG_DATA_HOME-$HOME/.local/share}/zsh/history.db

        # Setup history search widgets early
        if autoload history-search-end; then
          zle -N history-beginning-search-backward-end history-search-end
          zle -N history-beginning-search-forward-end  history-search-end
        fi
      '';

      # Zsh plugins
      plugins = [
        # Syntax highlighting
        {
          name = "fast-syntax-highlighting";
          src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
        }
        # Command suggestions based on history
        {
          name = "zsh-autosuggestions";
          file = "zsh-autosuggestions.zsh";
          src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
        }
        # SQLite-based history database
        {
          name = "zsh-histdb";
          src = pkgs.fetchFromGitHub {
            owner = "larkery";
            repo = "zsh-histdb";
            rev = "30797f0c50c31c8d8de32386970c5d480e5ab35d";
            hash = "sha256-PQIFF8kz+baqmZWiSr+wc4EleZ/KD8Y+lxW2NT35/bg=";
          };
        }
        # Fuzzy history search for histdb
        {
          name = "zsh-histdb-skim";
          src = "${pkgs.zsh-histdb-skim}/share/zsh-histdb-skim";
        }
      ];
    };
  };

  # Persist shell history across boots
  environment.persistence."/persist" = {
    users.gabehoban = {
      directories = [ ".local/share/zsh" ]; # Directory for history files
    };
  };
}
