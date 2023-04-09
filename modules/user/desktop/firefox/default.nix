{
  config,
  lib,
  pkgs,
  sysPlasma5,
  ...
}: {
  config = let
    cfg = config.tgap.user.desktop;
    inherit (lib) mkIf;
  in
    mkIf (sysPlasma5 && cfg.applications.enable) {
      programs.firefox = {
        enable = true;

        profiles = {
          default = {
            id = 0;
            name = "default";

            search = {
              force = true;
              default = "Startpage";
              order = [
                "Startpage"
                "DuckDuckGo"
              ];

              engines = {
                Startpage = {
                  urls = [
                    {template = "https://startpage.com/sp/search?query={searchTerms}";}
                  ];
                  definedAliases = ["@startpage" "@sp"];
                };
              };
            };

            extensions = with config.nur.repos.rycee.firefox-addons; [
              skip-redirect
              ublock-origin
            ];

            settings = {
              "browser.uiCustomization.state" =
                ''{''
                + ''"placements": {''
                + ''"widget-overflow-fixed-list": [],''
                + ''"unified-extensions-area": [''
                + ''"skipredirect_sblask-browser-action"''
                + ''],''
                + ''"nav-bar": [''
                + ''"back-button",''
                + ''"forward-button",''
                + ''"stop-reload-button",''
                + ''"urlbar-container",''
                + ''"save-to-pocket-button",''
                + ''"downloads-button",''
                + ''"fxa-toolbar-menu-button",''
                + ''"ublock0_raymondhill_net-browser-action"''
                + ''],''
                + ''"toolbar-menubar": ["menubar-items"],''
                + ''"TabsToolbar": [''
                + ''"tabbrowser-tabs",''
                + ''"new-tab-button",''
                + ''"alltabs-button"''
                + ''],''
                + ''"PersonalToolbar": [''
                + ''"import-button",''
                + ''"personal-bookmarks"''
                + '']''
                + ''},''
                + ''"seen": [''
                + ''"developer-button",''
                + ''"ublock0_raymondhill_net-browser-action",''
                + ''"skipredirect_sblask-browser-action"''
                + ''],''
                + ''"dirtyAreaCache": [''
                + ''"nav-bar",''
                + ''"PersonalToolbar",''
                + ''"toolbar-menubar",''
                + ''"TabsToolbar",''
                + ''"unified-extensions-area"''
                + ''],''
                + ''"currentVersion": 19,''
                + ''"newElementCount": 3''
                + ''}'';
            };

            extraConfig = ''
              ${builtins.readFile ./arkenfox-user.js}

              // User Overrides

              // DNS over HTTPS
              // Quad 9: https://dns.quad9.net/dns-query
              user_pref("network.trr.uri", "https://dns.quad9.net/dns-query");
              user_pref("network.trr.custom_uri", "https://dns.quad9.net/dns-query");
              user_pref("network.trr.mode", 2);

              // Leave IPv6 enabled.
              user_pref("network.dns.disableIPv6", false);

              // Reenable search engines.
              user_pref("keyword.enabled", true);
              // Enable favicons, the icons in bookmarks
              user_pref("browser.shell.shortcutFavicons", true);

              // Strict third party requests, may cause images/video to break.
              // Must use "Smart Referrer" extension if set to 0.
              user_pref("network.http.referer.XOriginPolicy", 2);

              // Enable playing DRM content.
              user_pref("media.gmp-widevinecdm.enabled", true);
              user_pref("media.eme.enabled", true);

              // Autoplaying settings
              // 0=Allow all, 1=Block non-muted media (default), 5=Block all
              user_pref("media.autoplay.default", 5);

              // WebGL is a security risk, but sometimes breaks things like 23andMe
              // or Google Maps (not always).
              user_pref("webgl.disabled", true);

              // Disable Pocket, it's proprietary trash.
              user_pref("extensions.pocket.enabled", false);
              // Disable Mozilla account.
              user_pref("identity.fxaccounts.enabled", false);
            '';
          };
        };
      };
    };
}
