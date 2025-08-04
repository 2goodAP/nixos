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
          searxBaseURL = "https://searx.oloke.xyz";
          searxPrefs =
            "?preferences="
            + "eJx1WMuu4zgO_ZrJxqige6rRg15kNUBvZ4CpvUFLtM2yLPrqkcT364eK86DiW4ubqhxJFEWR"
            + "h0cxkHDgQBhPA3oM4A4O_JBhwBPkxAfHBhye0B_KV8Pz4jDhaWAeHB56OJNh3waM7M4YTuAc"
            + "RrTnA81iol0CX9fTj5DxMGMa2Z7--5___ThE6GUWBDOefj-kEWc8RSqWD2IouxRbsenx0ibo"
            + "ttWW6bUJg3w9chgO26o2ptXd_TXoE4YWHA1-lv9vy8GewRu07X3Xv8FFPHxkDGtLvk2UZP0G"
            + "ku_JUxKjJrBz2_ptWfHKbAFbxZJDczc_cppwjSeLPYj7hxxc23OYISXyw2kJmNJ6sBShc-IE"
            + "-oG8RPz7n7_dDbf34P_jn_9-gs2ZLHJs2-1fGfprgKFtWQIW5BuYPns1KkHpsIlySVPb3sL_"
            + "hm4Gv17RQLbEyrjDK3gbCLRv4BZxvHHk87VZwExlE7XIR9DfQFLDKsTTlWNzoYnUrDjpHTog"
            + "m3dAsx1HHWuDJ6Be2S-WF7S1zx05Kn_q3B0lM2a54grqspkwvax1S1fZSZYGCX9P7uYBL-gl"
            + "GSMqr-ay-dEYc7TauBmxn7hc88O2cZxt7yAgkN7ELJIrPQaUZFWzA8coeIVc7JmkQtTiFZe3"
            + "r_u4FVAKS12ayaFst-qlFvFTiug5x2JMkEitsnZoJNtLpRD7qBcXY3K-fWajOE22vi4Lqbot"
            + "K5dQ_gZ-c1MNXBAK-BrDmX8-Lv6BSeHhitX2aZ3ZS-6qyMoBbBohzUJBKkp9QKkL7tNFbqix"
            + "FKTSS82_1gXyE4HRa9ZVnW1A-hyFTxQiHAOdijtb7DAM1QyU7OFZQcxWcsTGChLmbRYHazOz"
            + "5IBmiBG6AOXjNX-UMsVQB3PEq84lobR41NVPrlk4qloY8yCUNfSg01KBTbnHiCl-PRqFKzRR"
            + "0GxVJMiDOoJcZJCsWlVo6YNWXb8_KY7K24mEiGJ8lebnNyn5AOXCHtAdaLhvhJQGaSW6Khx3"
            + "MeExKBelXYFZwCuESh1KUjROUlsP8OdYVfF8mTunAV-apPypM_hFXbNfAV6-ztm5M1jps1Vp"
            + "KLiRw5yr5Ga7RtScI60LZlUPha6eUdGgHBS5hgIurMK5ET3pfJA2IF0WC_QM4lJKUHmw0BU6"
            + "SdIdBz0Gdv1tYWsgSuVanZ_CiHsueYJfmH8OPTb4alldEEvuhLLPFeDINJZnIL_t0ZR1dNY8"
            + "8ZEhVO3rBuxd-riAT9W8Avxi3j4uAa0lFf1Aw5ik5FibDJyS6B1xOLGute288xqLplHzIw-c"
            + "d8Depw3e-bTBFzTCnoqlKZoc43FZReypEjFg7Vqobc5bbb8S6dvIDr8a2hwvNNmUDz0wS5jk"
            + "dqKRtaC4TrpUSEsRnvpcD_CLswnhqjJMPK2cWMhlKoX_yP9UZsteUIUrVRy2wsjVdZxprrTW"
            + "hbqqxZbm1zFP8R38yFxfVAEj52D26ILmxv8VXBpyVeVlalEqt-jWFs68vkXrwq4PwhxuGSv2"
            + "-f37939dXzGx2aLXV_LpSyQVW_FPxGmP7C_hjtcFeetsCzlWyeWF80JFqwXYG9zg2t6G7Ssr"
            + "d-uAs2YCxJByp6n0pupkeCqC64KdGlqhFk7l-96hkKUfaItO7uPWE3WCcLCeJnVtfKWJvfBS"
            + "E1fPfp2rGsDp_Ywbtk_yG7wv4BTAVKSUrxdp2GrlmcnetH6dS7OoviplUgpHUtkgfabqpVv2"
            + "iuKuVEzFy9NwHLim4IhenmCiL-WZpruwR1Es0oXVO-KAvn5ZgfcQX4T9yFpYpmamEDhoTF6Q"
            + "jXyWh1DQk8dZC8pb19hePm8vmCBcpF9c4UrqGJ08owzMi0JuUdYvFD988cIpaH3BN2h3kRI0"
            + "Ej4UN9Rqy0X1NWNWHPWS0L9Q3Dsf1Nhu2y1uMywCymehiKuWwzZwEfuPaPbSTqegJogHlLWu"
            + "Lc1LCRFRw5X3m-7Vnt-V8M7rO17H7g7ujnHHd61Ey2w5qpJD0mBR3sWuKaJO7zvePXyp3CHr"
            + "Ezuc57V5dDrSTXobyhHDDixCfAcWIxKvWNXcTeCW8ESKtfJFqXUfHdSNRZJ5ONcSU9QXW_bv"
            + "njzxEeIo7VAP2UoiX28vW71S3kn6rVb0JciDav9geIxs0gvu70o9KpSFmCTZHhm32E7Fexml"
            + "efvnWJGjxznHUpwvuVEeOyI-lbrN3YzK42VdVHFviqxOpQCWWCQ4X6I-WcCcqqhFaWDwkK5K"
            + "OGUhhDpKIlHMxNKheseX6reR3GWfspqZ5XmUq31f-uatHbAjK5QWtkR5qhkO-peI7KPkeBz1"
            + "bwRFy7wZWzm_dUUL5ORBXa6pkjkT1SsLUtJVbvO4K1U9uCtNPfj285Qeuh1MKRMy6ZN9lemz"
            + "9M5ZHvDNsw5spRDPQ3nyKL-EiVL5bUDH-QLOjSIjvCbp93fYDdifc4N3J9zgN5JPfzx-ZXr9"
            + "Yri4LI0tnp6N7gEYcCbLgTgcRL1KiZz-D6LMQJw=";
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
