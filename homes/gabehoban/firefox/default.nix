{pkgs, ...}: let
  engines = import ./engines.nix;
in {
  programs.firefox = {
    enable = true;

    profiles = {
      default = {
        containersForce = true;

        containers = {
          personal = {
            color = "purple";
            icon = "circle";
            id = 1;
            name = "Personal";
          };

          private = {
            color = "red";
            icon = "fingerprint";
            id = 2;
            name = "Private";
          };

          atolls = {
            color = "blue";
            icon = "briefcase";
            id = 3;
            name = "Atolls";
          };
        };

        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          augmented-steam
          bitwarden
          clearurls
          consent-o-matic
          raindropio
          simple-tab-groups
          ublock-origin
          zoom-redirector
        ];

        id = 0;

        search = {
          inherit engines;
          default = "DuckDuckGo";
          force = true;

          order = [
            "Bing"
            "Brave"
            "DuckDuckGo"
            "Google"
            "Home Manager Options"
            "Kagi"
            "NixOS Wiki"
            "nixpkgs"
            "Noogle"
            "Wikipedia"
            "Wiktionary"
          ];
        };

        settings =
          (import ./betterfox.nix)
          // {
            "browser.toolbars.bookmarks.visibility" = "newtab";
            # "services.sync.prefs.sync.browser.uiCustomization.state" = true;
            "sidebar.revamp" = true;
            "sidebar.verticalTabs" = true;
            "svg.context-properties.content.enabled" = true;
          };
      };
    };
  };
}
