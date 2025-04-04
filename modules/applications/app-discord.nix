# modules/applications/app-discord.nix
#
# Discord communication client with Vencord enhancements
{ pkgs, ... }:
{
  #
  # Discord installation
  #
  environment.systemPackages = [
    # Use Discord PTB (Public Test Build) with enhancements
    (pkgs.discord-ptb.override {
      # Open-source ASAR implementation for improved security and transparency
      withOpenASAR = true;
      # Vencord client mod for enhanced features and customization
      withVencord = true;
    })
  ];

  #
  # Persistent configuration
  #
  impermanence.users.gabehoban.directories = [
    # Store Discord configurations in persistent storage
    # Discord PTB configuration
    ".config/discordptb"
    # Regular Discord configuration (backup)
    ".config/discord"
    # Vencord plugin configuration
    ".config/Vencord"
  ];
}
