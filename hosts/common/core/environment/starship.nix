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
          "($username )" # Username when needed
          "($hostname )" # Hostname when on SSH
          "$directory " # Current directory
          "($git_branch )" # Git branch
          "($git_commit )" # Git commit
          "$git_state" # Git state (rebasing, etc.)
          "$git_status" # Git status indicators
          "$character" # Prompt character
        ];

        # Right prompt format
        right_format = lib.concatStrings [
          "($status )" # Exit status
          "($cmd_duration )" # Command duration
          "($jobs )" # Background jobs
          "($python )" # Python environment
          "($rust )" # Rust environment
          "$time" # Current time
        ];

        # Timeout for commands (milliseconds)
        command_timeout = 60;

        # === Module configurations ===

        # Username display
        username = {
          format = "[$user]($style)";
          style_root = "bold red"; # Root user style
          style_user = "bold purple"; # Normal user style
          aliases.root = ""; # Don't show "root" text
        };

        # Hostname display (only in SSH sessions)
        hostname = {
          format = "[$hostname]($style)[$ssh_symbol](green)";
          ssh_only = true;
          ssh_symbol = " 󰣀"; # SSH indicator icon
          style = "bold red";
        };

        # Directory display
        directory = {
          format = "[$path]($style)[$read_only]($read_only_style)";
          fish_style_pwd_dir_length = 1; # Shortened path style
          style = "bold blue";
        };

        # Prompt character
        character = {
          success_symbol = "\\$"; # Default shell prompt symbol
          error_symbol = "\\$"; # Same symbol but with error color
          # Vim mode indicators
          vimcmd_symbol = "[](bold green)";
          vimcmd_replace_one_symbol = "[](bold purple)";
          vimcmd_replace_symbol = "[](bold purple)";
          vimcmd_visual_symbol = "[](bold yellow)";
        };

        # Git branch display
        git_branch = {
          format = "[$symbol$branch]($style)";
          symbol = " "; # Branch icon
          style = "green";
        };

        # Git commit display
        git_commit = {
          commit_hash_length = 8; # Short SHA
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
            "[($conflicted )](red)" # Conflicts in red
            "[($stashed )](magenta)" # Stashed changes in magenta
            "[($staged )](green)" # Staged changes in green
            "[($deleted )](red)" # Deleted files in red
            "[($renamed )](blue)" # Renamed files in blue
            "[($modified )](yellow)" # Modified files in yellow
            "[($untracked )](blue)" # Untracked files in blue
            "[($ahead_behind )](green)" # Branch status in green
          ];
        };

        # Exit status display
        status = {
          disabled = false; # Always show error status
          pipestatus = true; # Show all pipeline exit codes
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
          disabled = false; # Always show time
        };
      };
    };
  };
}
