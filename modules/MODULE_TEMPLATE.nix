# modules/category/module-name.nix
#
# Brief description of the module's purpose
{
  pkgs,
  config,
  lib,
  ...
}:

{
  #
  # Main configuration section
  #
  setting = {
    # Configuration with explanatory comments
    option1 = true;
    option2 = "value";
  };

  #
  # Secondary configuration section
  #
  another = {
    # More configuration
    some = "value";
  };

  #
  # Package definitions
  #
  environment.systemPackages = with pkgs; [
    # Packages listed alphabetically or by function
    # with comments explaining non-obvious packages
    package1
    package2
  ];

  #
  # Persistence configuration
  #
  # System-level persistence
  impermanence.directories = [
    # Directories to persist 
  ];
  
  # User-level persistence
  impermanence.users.username.directories = [
    # User directories to persist
  ];
}
