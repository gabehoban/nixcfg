# modules/applications/app-claude.nix
#
# Claude AI client configuration
{
  pkgs,
  ...
}:
{
  #
  # Claude Desktop application and dependencies
  #
  environment.systemPackages = [
    # UV Python package manager (dependency for codemcp)
    pkgs.uv

    # Claude client with FHS compatibility
    pkgs.claude-code
  ];

  #
  # Claude Desktop configuration
  #
  home-manager.users.gabehoban = {
    # Configure Claude Desktop with codemcp support
    home.file.".config/Claude/claude_desktop_config.json".text = ''
      {
        "mcpServers": {
          "codemcp": {
            "command": "uvx",
            "args": [
              "--from",
              "git+https://github.com/ezyang/codemcp@prod",
              "codemcp"
            ]
          }
        }
      }
    '';
  };

  #
  # Persistence configuration
  #
  environment.persistence."/persist" = {
    users.gabehoban.directories = [
      # Persist Claude configuration across reboots
      ".config/Claude"
    ];
  };
}
