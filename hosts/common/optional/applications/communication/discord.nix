# Discord communication client with Vencord enhancements
{ pkgs, ... }:
{
  #
  # Discord installation
  #
  environment.systemPackages = [
    # Use Discord PTB (Public Test Build) with enhancements
    (pkgs.discord-ptb.override {
      withOpenASAR = true; # Open-source ASAR implementation for improved security and transparency
      withVencord = true; # Vencord client mod for enhanced features and customization
    })
  ];

  #
  # Persistent configuration
  #
  environment.persistence."/persist" = {
    users.gabehoban.directories = [
      # Store Discord configurations in persistent storage
      ".config/discordptb" # Discord PTB configuration
      ".config/discord" # Regular Discord configuration (backup)
      ".config/Vencord" # Vencord plugin configuration
    ];
  };
}
