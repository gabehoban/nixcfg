# Claude AI desktop client configuration
{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  #
  # Claude Desktop application and dependencies
  #
  environment.systemPackages = [
    # UV Python package manager (dependency for codemcp)
    pkgs.uv

    # Claude Desktop client with FHS compatibility
    (inputs.claude-desktop.packages.x86_64-linux.claude-desktop-with-fhs.overrideAttrs (
      _final: _prev: {
        # Set appropriate license metadata
        meta.license = lib.licenses.free;
      }
    ))
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
