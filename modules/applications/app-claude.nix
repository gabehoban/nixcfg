# modules/applications/app-claude.nix
#
# Claude AI client configuration
{
  inputs,
  pkgs,
  system,
  ...
}:
{
  #
  # Claude Desktop application and dependencies
  #
  environment.systemPackages = [
    # Claude client with FHS compatibility
    pkgs.claude-code
  ];

  #
  # Claude Desktop configuration
  #
  home-manager.users.gabehoban = {
    home.packages = [
      pkgs.uv
      inputs.claude-desktop.packages.${system}.claude-desktop-with-fhs
    ];

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
  impermanence.users.gabehoban.directories = [
    # Persist Claude configuration across reboots
    ".config/Claude"
  ];
}
