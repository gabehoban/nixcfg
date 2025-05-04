# modules/core/shell/starship.nix
#
# Starship prompt configuration
# Configures the cross-shell prompt with useful information
{ lib, ... }:
{
  home-manager.users.gabehoban = {
    programs.starship = {
      enable = true;
      settings = {
        # Don't add a newline at the start of the prompt
        add_newline = false;

        # Left prompt format
        format = lib.concatStrings [
          # Username when needed
          "($username )"
          # Hostname when on SSH
          "($hostname )"
          # Current directory
          "$directory "
          # Git branch
          "($git_branch )"
          # Git commit
          "($git_commit )"
          # Git state (rebasing, etc.)
          "$git_state"
          # Git status indicators
          "$git_status"
          # Prompt character
          "$character"
        ];

        # Right prompt format
        right_format = lib.concatStrings [
          # Exit status
          "($status )"
          # Command duration
          "($cmd_duration )"
          # Background jobs
          "($jobs )"
          # Python environment
          "($python )"
          # Rust environment
          "($rust )"
          # Current time
          "$time"
        ];

        # Timeout for commands (milliseconds)
        command_timeout = 60;

        # === Module configurations ===

        # Username display
        username = {
          format = "[$user]($style)";
          # Root user style
          style_root = "bold red";
          # Normal user style
          style_user = "bold purple";
          # Don't show "root" text
          aliases.root = "";
        };

        # Hostname display (only in SSH sessions)
        hostname = {
          format = "[$hostname]($style)[$ssh_symbol](green)";
          ssh_only = true;
          # SSH indicator icon
          ssh_symbol = " 󰣀";
          style = "bold red";
        };

        # Directory display
        directory = {
          format = "[$path]($style)[$read_only]($read_only_style)";
          # Shortened path style
          fish_style_pwd_dir_length = 1;
          style = "bold blue";
        };

        # Prompt character
        character = {
          # Default shell prompt symbol
          success_symbol = "\\$";
          # Same symbol but with error color
          error_symbol = "\\$";
          # Vim mode indicators
          vimcmd_symbol = "[](bold green)";
          vimcmd_replace_one_symbol = "[](bold purple)";
          vimcmd_replace_symbol = "[](bold purple)";
          vimcmd_visual_symbol = "[](bold yellow)";
        };

        # Git branch display
        git_branch = {
          format = "[$symbol$branch]($style)";
          # Branch icon
          symbol = " ";
          style = "green";
        };

        # Git commit display
        git_commit = {
          # Short SHA
          commit_hash_length = 8;
          format = "[$hash$tag]($style)";
          style = "green";
        };

        # Git status indicators
        git_status = {
          # Status symbols
          conflicted = "$count";
          ahead = "⇡$count";
          behind = "⇣$count";
          diverged = "⇡$ahead_count⇣$behind_count";
          untracked = "?$count";
          stashed = "\\$$count";
          modified = "!$count";
          staged = "+$count";
          renamed = "→$count";
          deleted = "-$count";

          # Combined status format with color coding
          format = lib.concatStrings [
            # Conflicts in red
            "[($conflicted )](red)"
            # Stashed changes in magenta
            "[($stashed )](magenta)"
            # Staged changes in green
            "[($staged )](green)"
            # Deleted files in red
            "[($deleted )](red)"
            # Renamed files in blue
            "[($renamed )](blue)"
            # Modified files in yellow
            "[($modified )](yellow)"
            # Untracked files in blue
            "[($untracked )](blue)"
            # Branch status in green
            "[($ahead_behind )](green)"
          ];
        };

        # Exit status display
        status = {
          # Always show error status
          disabled = false;
          # Show all pipeline exit codes
          pipestatus = true;
          pipestatus_format = "$pipestatus => [$int( $signal_name)]($style)";
          pipestatus_separator = "[|]($style)";
          pipestatus_segment_format = "[$status]($style)";
          format = "[$status( $signal_name)]($style)";
          style = "red";
        };

        # Python environment
        python = {
          format = "[$symbol$pyenv_prefix($version )(\($virtualenv\) )]($style)";
        };

        # Command duration
        cmd_duration = {
          format = "[ $duration]($style)";
          style = "yellow";
        };

        # Time display
        time = {
          format = "[ $time]($style)";
          style = "cyan";
          # Always show time
          disabled = false;
        };
      };
    };
  };
}
