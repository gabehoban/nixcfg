# modules/category/module-name.nix
#
# Brief description of the module's purpose
{
  pkgs,
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
  environment.persistence."/persist" = {
    # System-level persistence
    directories = [
      # Directories to persist
    ];

    # User-level persistence
    users.username = {
      directories = [
        # User directories to persist
      ];
    };
  };
}
