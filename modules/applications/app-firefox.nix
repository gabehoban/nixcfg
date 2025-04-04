# modules/applications/app-firefox.nix
#
# Firefox browser configuration with privacy-focused settings
_: {
  programs.firefox = {
    enable = true;

    #
    # Firefox organizational policies
    #
    policies = {
      # Disable various Mozilla services
      DisableAppUpdate = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableSetDesktopBackground = true;

      # Configure Firefox Home page
      FirefoxHome = {
        Search = true;
        TopSites = true;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = false;
        Locked = true;
      };

      # Disable Firefox Suggest features
      FirefoxSuggest = {
        ImproveSuggest = false;
        Locked = false;
        SponsoredSuggestions = false;
      };

      # Homepage settings
      Homepage = {
        URL = "about:home";
        Locked = true;
        StartPage = "homepage";
      };

      # Disable autofill and password manager
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      PasswordManagerEnabled = false;

      # Other browser settings
      NoDefaultBookmarks = true;
      SearchBar = "unified";
      SearchSuggestEnabled = true;
      ShowHomeButton = false;

      #
      # Extensions management
      #
      ExtensionSettings = {
        # Block manual installation of extensions
        "*" = {
          blocked_install_message = "You can't have manual extension mixed with nix extensions";
          installation_mode = "blocked";
        };

        # Privacy extensions
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
        "jid1-MnnxcxisBPnSXQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
          installation_mode = "force_installed";
        };

        # Password manager
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
      };
    };

    #
    # Firefox preferences (about:config)
    #
    preferences = {
      # Hardware acceleration
      "media.ffmpeg.vaapi.enabled" = true;

      # Disable telemetry and data collection
      "app.shield.optoutstudies.enabled" = false;
      "datareporting.healthreport.uploadEnabled" = false;
      "datareporting.policy.dataSubmissionEnabled" = false;

      # Disable all telemetry endpoints
      "toolkit.telemetry.archive.enabled" = false;
      "toolkit.telemetry.bhrPing.enabled" = false;
      "toolkit.telemetry.coverage.opt-out" = true;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.firstShutdownPing.enabled" = false;
      "toolkit.telemetry.hybridContent.enabled" = false;
      "toolkit.telemetry.newProfilePing.enabled" = false;
      "toolkit.telemetry.prompted" = 2;
      "toolkit.telemetry.rejected" = true;
      "toolkit.telemetry.reportingpolicy.firstRun" = false;
      "toolkit.telemetry.shutdownPingSender.enabled" = false;
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.unifiedIsOptIn" = false;
      "toolkit.telemetry.updatePing.enabled" = false;
    };
  };

  #
  # User profile persistence
  #
  impermanence.users.gabehoban.directories = [
    ".mozilla" # Firefox profiles, settings, and extensions
    ".cache/mozilla" # Firefox cache
  ];
}
