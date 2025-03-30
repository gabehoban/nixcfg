# modules/core/locale.nix
#
# Locale and timezone configuration
# Sets system language and time settings
_: {
  # Set timezone to Eastern Time
  time.timeZone = "America/New_York";

  # Set system-wide locale to US English with UTF-8 encoding
  i18n.defaultLocale = "en_US.UTF-8";
}