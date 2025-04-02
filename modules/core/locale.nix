# modules/core/locale.nix
#
# Locale and timezone configuration
# Sets system language and time settings
_: {
  #
  # Timezone configuration
  #
  # Set timezone to Eastern Time
  time.timeZone = "America/New_York";

  #
  # Locale configuration
  #
  # Set system-wide locale to US English with UTF-8 encoding
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure additional locales if needed
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
  ];
}
