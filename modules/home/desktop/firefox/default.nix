{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop;
  osCfg = osConfig.tgap.system;
  inherit (lib) mkIf optionalString;
in
  mkIf (osCfg.desktop.enable && cfg.applications.enable) {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-beta;

      profiles = {
        default = let
          searxBaseURL = "https://baresearch.org";
          searxPrefs =
            "?preferences="
            + "eJx1WMuu67oN_ZpmYtyg7S1QdJBRgU5vgd65QUuMzWM9fPRI4v31Jf2IpXifwc6O"
            + "SYuiyMVFKgoS9j4QxluPDgOYiwHXZ-jxBoYfvAKDN3QXyMkrbyeDCW-9973Byx0e"
            + "pLxrA0ZvHhhuF7K8sp2Cf823P0PGi8U0eH377x__-_MS4Y4RIajh9tdLGtDiLZJY"
            + "vLCBbFJs2ZbDZ5ugW1drT4dxD_x49aG_rKvamGb2TRy7KHQJQwuGemf5-7oc9AOc"
            + "Qt1uu_4HTMTLz4xhbsm1iRKvX4Xk7uQosVEVvDHr-nWZeKXWOM1syaDazA8-jTjH"
            + "m8Y7sPuXHEx798FCSuT62xQwpfmiKUJn2Al0PTkO9L966Ns2ekVgGoua4C9__zef"
            + "rcMmcozHtl2iGGtp8yCNvm2Xf586yJpYZ3MkJSqDL3A6ELTtltZFOvH-jSGXX80E"
            + "apRNeLMkOucgNnJaemDb3sms-08c54Y_ZZ9QKuJYmu7IkPwV7nVTV72RNPX9YWA5"
            + "91UpddVYrFLGZ303EBCoXM5JeeoHMTYK4YzTx2OzRq6IoAgZUiyST7HEWSKsbOcQ"
            + "0Km5lGnEL8bTO6IaY4JEbMYzcINIdN9w4gU05F0sF4sxPsiGnlLBpyBd2MhqlL_e"
            + "r9mNRSQK3RNBFhzr0PofNEkEDxlDDufqXH97FXFgR3UaIFmuulIckDHk7-nJIW80"
            + "BQa3wHxFxT2QGwlUuWCeiwP0SF8D108h8V5z8nQtYrJoJgOzQCkeICg11nN6ywBw"
            + "GWGQEhGKKVM6QBdAPjYvB3xt38hBYYAjFDg7c7H0B8XBH559_cawDSDn3V0yvosJ"
            + "r2EvDOYvUBO4_dF_DRUw7dN2phS4GeAw5_UcsQS4n9C9N939ECFvhL4WBZx8Ea21"
            + "ZCmmzRfmlzPE3sJzKRyqHWzfLauKZcod1-dj2_DnE1wqVy2C80YBtaZ0orhA_ZAa"
            + "Db40se5q5yjcWxYlaD1fueHYvOVwOTL9NniDJ_lqRXmNjXy8pZb9I9VExauA8RIV"
            + "cXGi6BKENEmzKjZNfpx98oyRUTK-Bz7JudgG5OrlQrqF60G2ougndRWrPL25B7BM"
            + "xEPFzDprdEfuI345sBXK_A_E8Sw5x34po4mMT4c9Bw9hjyLbiCHlrsTlkiR-fxSS"
            + "fWJXqGaouVGev0l65kIoLRruJJExW8qe_kWjd4ypJs7Ou1nI6Dg2jqHG3yo67bWK"
            + "T5QZUwBVATQ-eimiYmnyPgkXSkA-8PnwpJfmuMHnSSNZ5vfq7NlaU1Qul_LBFUxn"
            + "VZTH_tr7vX4u6OoxAKaxsRSCD0VbdcBkp2HvylKQa78WZ95SxnQ5JIQXPUpsd9z7"
            + "FdjpaF-yeusXZdN2_efzOdaLtErKIjkFv6PUcbvCnZ2EwBh2sew2asD76IWw9vip"
            + "iZnnjtJ_96rlVh8jC8sTcQyJS5lPXljTPPlgaIbcFQnTkD5Ka2-j30vPBy501bHX"
            + "WciCNDD-lDacZuuZzV0B4rsOXlr8ntG7ITWGwjw7QTkeqeHnJLhZEcQTKXTHw3E2"
            + "obUOQ3_oEIQGD-j1puKyrbeejrfJq6NtslNON_k39DmAxH41smWN23W80n6SYXNo"
            + "7ctWd0eIyPa5jAg53pB8LncuZHugRg4kxKIfGrR2bvZWsAwPHxW9vpEjhl_puMGm"
            + "X-nEMifnG_XavxsJdqTSo03h77zYMfXEMvKiRaYoFw3UzY4h1D8q2FrggVt79wvn"
            + "3-oB4sCN6Js39HtkodcyVR-RdNMOG-6PI2EoShZ4BJQairgc_J3wXccTASMatpm3"
            + "1jP_Iiaujb1AJi095nhp4hsTX6Z2LcmdDWNZ05PQVIGD5fm6OH74P5GArYNibJs8"
            + "M15MQuyvA2mrs432FsitpXDccY49c2dl08LPedrJdh1xqmpZRadiCcCAbToe8WN5"
            + "cwg-JSlxHmc9xrLbTQT7_Ha0MJ-Zu-t08aiiRs9cejf-ufeAOOYuu5T3USfzsJvj"
            + "O5V86VQ5xus08_V7RwLfo0nzeB9WVL_Hm6o6s4s8j8ehvEPBUHe2RVAHZfb5Y6J4"
            + "S953KCDDhCnQqWakkTrvx2ocFWFlXgQ_s6_LRoQcsKDO0gnVQgi_EB-pZrE4VI3j"
            + "8qq0rmW-rC08_PwxM4pUmILr4Xoi21J5Akyp_LjAl6olTUe2NKn05V3lg-U5yvK1"
            + "rXmzi64ugr___s9XcfVeR8cqviF3c492Z_OnD9rRWIQEjBl4jHTl4VIKVyrmVia_"
            + "R-XXIjhHZRWfJ4hFXM9_S3aHvA8VXfrH_hvC8bvKZDJPVPH2nrB2gVTX67o9XRUY"
            + "lTk2fq2-UiUsuq0667hD8DS-zZ2lxkO7_j71DNyNT-qI5t6Su_uThl1oeRRS41kT"
            + "lr7ayi9JgVP6wLOz0uxabi-sY_q88J2Fmff2f_X7eOI=";
        in {
          id = 0;
          name = "default";

          search = let
            defaultEngine = "SearXNG";
          in {
            force = true;
            default = defaultEngine;
            privateDefault = defaultEngine;

            order = [
              "${defaultEngine}"
              "NixPackages"
              "HomeManagerOptions"
              "Startpage"
              "ddg"
            ];

            engines = {
              HomeManagerOptions = {
                definedAliases = ["@hmopts" "@hm"];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

                urls = [
                  {
                    template = "https://home-manager-options.extranix.com";
                    params = [
                      {
                        name = "release";
                        value = "master";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
              };

              NixPackages = {
                definedAliases = ["@nix" "@np"];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "channel";
                        value = "unstable";
                      }
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
              };

              Noogle = {
                definedAliases = ["@no" "@ng"];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

                urls = [
                  {
                    template = "https://noogle.dev/q";
                    params = [
                      {
                        name = "term";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
              };

              "${defaultEngine}" = {
                definedAliases = ["@searx" "@sx"];
                icon =
                  "https://github.com/searxng/searxng/blob/master/searx"
                  + "/static/themes/simple/img/favicon.png?raw=true";
                updateInterval = 24 * 60 * 60 * 1000; # every day

                urls = [
                  {
                    template = "${searxBaseURL}/${searxPrefs}";

                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
              };

              Startpage = {
                definedAliases = ["@startpage" "@sp"];
                icon = "https://support.startpage.com/favicon.ico";
                updateInterval = 24 * 60 * 60 * 1000; # every day

                urls = [
                  {
                    params = [
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];

                    template =
                      "https://us.startpage.com/sp/search"
                      + "?&abp=1&t=device&lui=english"
                      + "&sc=YyhP7EwjtGmX00&cat=web&prfe=fb87077e586ff7276b"
                      + "486ed2188e443936775c3976b69d8f6550982948156465cb14"
                      + "e689e00738659b51db36277aa4d52cb1b1912381b9f483ed3f"
                      + "d0b226a682c306cf98c07621c8c236ad";
                  }
                ];
              };
            };
          };

          extensions.packages = let
            port-authority = pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
              pname = "port-authority";
              version = "2.1.0";
              addonId = "{6c00218c-707a-4977-84cf-36df1cef310f}";
              url = "https://addons.mozilla.org/firefox/downloads/file/4481055/port_authority-2.1.0.xpi";
              sha256 = "sha256-tui5a6c9Q5ZXsNSe5cJywnlaqtOsGcrLT5vFElE7Y7I=";

              meta = with lib; {
                homepage = "https://github.com/ACK-J/Port_Authority";
                description =
                  "Blocks websites from using javascript"
                  + " to port scan your computer/network";
                license = licenses.gpl2;
                mozPermissions = [
                  "webRequest"
                  "webRequestBlocking"
                  "storage"
                  "tabs"
                  "notifications"
                  "dns"
                  "<all_urls>"
                ];
                platforms = platforms.all;
              };
            };
          in
            with pkgs.nur.repos.rycee.firefox-addons; [
              port-authority
              search-by-image
              sidebery
              skip-redirect
              ublock-origin
              vimium
            ];

          settings = {
            "browser.ctrlTab.sortByRecentlyUsed" = true;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
            "browser.privatebrowsing.autostart" = true;
            "browser.startup.firstrunSkipsHomepage" = false;
            "browser.tabs.warnOnClose" = true;
            "browser.toolbars.bookmarks.visibility" = "never";
            "browser.uiCustomization.state" =
              ''{''
              + ''"placements":{''
              + ''"widget-overflow-fixed-list":[],''
              + ''"nav-bar":[''
              + ''"back-button",''
              + ''"forward-button",''
              + ''"stop-reload-button",''
              + ''"urlbar-container",''
              + ''"downloads-button",''
              + ''"fxa-toolbar-menu-button",''
              + ''"unified-extensions-button",''
              + ''"_3c078156-979c-498b-8990-85f7987dd929_-browser-action",''
              + ''"ublock0_raymondhill_net-browser-action"''
              + ''],''
              + ''"toolbar-menubar":["menubar-items"],''
              + ''"TabsToolbar":[''
              + ''"firefox-view-button",''
              + ''"tabbrowser-tabs",''
              + ''"new-tab-button",''
              + ''"alltabs-button"''
              + ''],''
              + ''"PersonalToolbar":["personal-bookmarks"],''
              + ''"unified-extensions-area":[''
              + ''"_2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c_-browser-action",''
              + ''"_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action",''
              + ''"skipredirect_sblask-browser-action",''
              + ''"_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action",''
              + ''"_6c00218c-707a-4977-84cf-36df1cef310f_-browser-action"''
              + '']''
              + ''},''
              + ''"seen":[''
              + ''"skipredirect_sblask-browser-action",''
              + ''"ublock0_raymondhill_net-browser-action",''
              + ''"developer-button"''
              + ''],''
              + ''"dirtyAreaCache":["unified-extensions-area","nav-bar"],''
              + ''"currentVersion":20,''
              + ''"newElementCount":3''
              + ''}'';
            "browser.urlbar.suggest.history" = false;
            "browser.urlbar.suggest.topsites" = false;

            "font.language.group" = "x-unicode";
            "font.name.monospace.ar" = "Noto Sans Mono";
            "font.name.monospace.he" = "Noto Sans Mono";
            "font.name.monospace.ja" = "Noto Sans Mono";
            "font.name.monospace.ko" = "Noto Sans Mono";
            "font.name.monospace.th" = "Noto Sans Mono";
            "font.name.monospace.x-armn" = "Noto Sans Mono";
            "font.name.monospace.x-being" = "Noto Sans Mono";
            "font.name.monospace.x-cans" = "Noto Sans Mono";
            "font.name.monospace.x-devanagari" = "Noto Sans Mono";
            "font.name.monospace.x-ethi" = "Noto Sans Mono";
            "font.name.monospace.x-geor" = "Noto Sans Mono";
            "font.name.monospace.x-khmr" = "Noto Sans Mono";
            "font.name.monospace.x-knda" = "Noto Sans Mono";
            "font.name.monospace.x-math" = "Noto Sans Mono";
            "font.name.monospace.x-mlym" = "Noto Sans Mono";
            "font.name.monospace.x-orya" = "Noto Sans Mono";
            "font.name.monospace.x-sinh" = "Noto Sans Mono";
            "font.name.monospace.x-tamil" = "Noto Sans Mono";
            "font.name.monospace.x-telu" = "Noto Sans Mono";
            "font.name.monospace.x-tibt" = "Noto Sans Mono";
            "font.name.monospace.x-unicode" = "Noto Sans Mono";
            "font.name.monospace.x-western" = "JetBrainsMono Nerd Font";
            "font.name.monospace.zh-CN" = "Noto Sans Mono";
            "font.name.monospace.zh-HK" = "Noto Sans Mono";
            "font.name.monospace.zh-TW" = "Noto Sans Mono";

            "places.history.enabled" = false;

            "privacy.donottrackheader.enabled" = true;
            "privacy.globalprivacycontrol.enabled" = true;

            "signon.generation.enabled" = false;
            "signon.management.page.breach-alerts.enabled" = false;
            "signon.rememberSignons" = false;

            "widget.use-xdg-desktop-portal.file-picker" = 1;
          };

          extraConfig = let
            betterfox = builtins.fetchTarball {
              url = "https://github.com/yokoffing/Betterfox/archive/refs/tags/138.0.tar.gz";
              sha256 = "sha256:0fr91rk62nhiid9403rcqv7q99imgblwnkrvf0xxgn9ji3h60bvj";
            };
          in ''
            ${builtins.readFile "${betterfox}/user.js"}

            /****************************************************************************
             * START: MY OVERRIDES                                                      *
            ****************************************************************************/
            // visit https://github.com/yokoffing/Betterfox/wiki/Common-Overrides
            // visit https://github.com/yokoffing/Betterfox/wiki/Optional-Hardening
            // Enter your personal overrides below this line:

            // PREF: disable Firefox Sync
            user_pref("identity.fxaccounts.enabled", false);

            // PREF: disable the Firefox View tour from popping up
            user_pref("browser.firefox-view.feature-tour", "{\"screen\":\"\",\"complete\":true}");

            // PREF: disable login manager
            user_pref("signon.rememberSignons", false);

            // PREF: disable address and credit card manager
            user_pref("extensions.formautofill.addresses.enabled", false);
            user_pref("extensions.formautofill.creditCards.enabled", false);

            // PREF: do not allow embedded tweets, Instagram, Reddit, and Tiktok posts
            user_pref("urlclassifier.trackingSkipURLs", "");
            user_pref("urlclassifier.features.socialtracking.skipURLs", "");

            // PREF: enable HTTPS-Only Mode
            // Warn me before loading sites that don't support HTTPS
            // in both Normal and Private Browsing windows.
            user_pref("dom.security.https_only_mode", true);
            user_pref("dom.security.https_only_mode_error_page_user_suggestions", true);

            ${optionalString (!osCfg.laptop.enable) ''
              // PREF: disable captive portal detection
              // [WARNING] Do NOT use for mobile devices!
              user_pref("captivedetect.canonicalURL", "");
              user_pref("network.captive-portal-service.enabled", false);
              user_pref("network.connectivity-service.enabled", false);
            ''}

            // PREF: enforce DNS-over-HTTPS (DoH)
            user_pref("network.trr.mode", 3);
            // PREF: set DoH provider (Quad9)
            user_pref("network.trr.uri", "https://dns.quad9.net/dns-query");

            // PREF: disable disk cache
            user_pref("browser.cache.disk.enable", false);

            // PREF: ask where to save every file
            user_pref("browser.download.useDownloadDir", false);

            // PREF: ask whether to open or save new file types
            user_pref("browser.download.always_ask_before_handling_new_types", true);

            // PREF: display the installation prompt for all extensions
            user_pref("extensions.postDownloadThirdPartyPrompt", false);

            // PREF: enforce certificate pinning
            // [ERROR] MOZILLA_PKIX_ERROR_KEY_PINNING_FAILURE
            // 1 = allow user MiTM (such as your antivirus) (default)
            // 2 = strict
            user_pref("security.cert_pinning.enforcement_level", 2);

            // PREF: delete all browsing data on shutdown
            user_pref("privacy.sanitize.sanitizeOnShutdown", true);
            user_pref("privacy.clearOnShutdown_v2.cache", true); // DEFAULT
            user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", true); // DEFAULT
            user_pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", true); // DEFAULT

            // PREF: after crashes or restarts, do not save extra session data
            // such as form content, scrollbar positions, and POST data
            user_pref("browser.sessionstore.privacy_level", 2);

            // Use search engine URL as the browser startup homepage.
            user_pref("browser.startup.page", 1);
            user_pref("browser.startup.homepage", "${searxBaseURL}/preferences${searxPrefs}");

            /****************************************************************************
             * SECTION: SMOOTHFOX                                                       *
            ****************************************************************************/
            // visit https://github.com/yokoffing/Betterfox/blob/main/Smoothfox.js
            // Enter your scrolling overrides below this line:

            // OPTION: SMOOTH SCROLLING (recommended for 90hz+ displays)
            user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
            user_pref("general.smoothScroll", true); // DEFAULT
            user_pref("general.smoothScroll.msdPhysics.enabled", true);
            user_pref("mousewheel.default.delta_multiplier_y", 300); // 250-400; adjust this number to your liking
          '';
        };
      };
    };
  }
