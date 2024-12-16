{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.desktop;
  osCfg = osConfig.tgap.system.desktop;
  inherit (lib) mkIf;
in
  mkIf (osCfg.enable && cfg.applications.enable) {
    programs.firefox = {
      enable = true;

      profiles = {
        default = let
          searxBaseURL = "https://baresearch.org";
          searxPrefs =
            "?preferences="
            + "eJx1WEuP5LgN_jWpi7GFJLPAIoc6Bch1A-zcDVli2RxLokePqnL_-iX9KEvtnkO7"
            + "W6QeFPnxI9VaJegpIMRbDx6CsherfJ9VDzeVE10saWXhBv4iQ01uspDg1hP1Fi7o"
            + "eGI7BXrNt-8hw8VBGsjc_v_nX98vUd0hggp6uP3zkgZwcIso6y8BYrYptuRbD882"
            + "qW5dbQhb1pF9QLiR4uGVQn9ZV7UxzXazSoNPEFplsfeO_16XK_NQXoNpt1P_p2yE"
            + "y88MYW7RtwkTr1-F6O_oMfGmOpC16_p1mVilV7fMvJMFvW0_UBphjjcDd8XmXwxG"
            + "1Vk-DnyPnj34n171bRtJo7KNA4PqH__-r7ITKxuLPr-aSemRPRbbFpPovFexkUPx"
            + "AW17RwtRxBNft-FvExOFUhHHtt3ixMMOLcpP2z7QAMmMbuqqGclg3x8bLEZdtdZX"
            + "A8Uq9sHTPJBDUaydYfo0bJZwi_HL703IEWSRfGWnHCxCuY4lAbyeK7PU4Ae6lyID"
            + "8MERbV2OqJdxTCoh70wMnSAS0zfsegkbko_lYtlfW9riVyr4YmiKPbIe5aenZr18"
            + "4YRC9wQlC4514OgHTuK8Q5Y4rHN11X-9CtewoSYNKjnGfSkOAE2ke3qqAI3BwPAS"
            + "oK2AuAf0IypdLpjn4gI94MfACC4kRCaAMrWIk7OZrJoFRfGIf6lxxBEvHeAY9EGg"
            + "i3rx79uEfiJjyuAMqgtKPpvZA7y2v9CrYscfGAc67Pr4jfEalNx2N8hSFxNcw54R"
            + "zB9KT8rvQ_oYsHSxe7rOlgI_K3VsR2aOUCKbJmCCSFBYIaIAExVuWdMSY9qOnQKc"
            + "sfQWntPgUO2o-mpZlShT7jgHH9uBP5_Kp3LVIjgfFMAYTCeOWQ9wcxRGK3ZBYUnP"
            + "Ll0ZJuqBrOKgRY2cMiDZqYyZr0zrLnNe7TCc8DeeCSf5eo4mA4183lLHxqJuvtif"
            + "kzikSYpEYVaicaZEjI1RIr1HIckleQ-Vq8mFdPPdA50E9B3kJ3YVvXDBeilvgmTr"
            + "IX2SvQflmI-HSm6yAX_AI8KHV67CHP0AGM-Sc3iWlJrQUjr28-ohqVMAAiCk3JUo"
            + "XeLI80fh4Cd0hWpWNXXK-AtcZE6Lckcr4WZYl7InvXAkz7Br4uzJz0JMx7VhDDVE"
            + "V9HprFV8os_4Y7pOz9KRKShdgTo-ekm8Yq9ElIQoxUOfMP0gNEvR3FD2xBEdk3_l"
            + "jOycnY8jmV4OKmGuq9w-9tee9py7gK9rt5rGxmEIFIpy6xUzoVF7tZYkXuu4GPOW"
            + "MvSLK6nwwkeZAh1DUSs3HfQpq7diUhZz338en52_SKsoLZJTNDpMHdcy2BlNSI9x"
            + "GMtSpAe4jyQkt_tPT8xWd5B6vSc3twYxsrC8EfsQOeP55sVuhvi40Ay5KwJmVPqU"
            + "a3uN_Vp6vnChq6699khOSXXjr9ToNDvyHJ8C1XcTSOr_u_6BxxyPSPTcEqrdYB4c"
            + "1gu_dRD6QwdK-PAAV28rUttK6-kCm7wyfpOdorbJv-DRQYl31022uHC1jlekvfA6"
            + "0x33RtfnUBiBns9AyuVhhWx3x4hcB2NRGC04Nzd7GVjahU9pus7IEcKvdFxp0690"
            + "sjO371-o10ahEf9GLC3aFHTnxZ75JJbOFi0w7_hoVV0KGRf9o8KiU9xdG_K_MP6t"
            + "HlQcuAh9McO82xR8cfuZzeFJP-1I4do4IoQiDxU3fZIYEZaLv2O867g1sMgvkLXL"
            + "rfVMqgCJAb-jfjJSSY5JE79S-AGza5cOAGKZqJNwT4GDZXxdDD_sn1Dw1amiVeMm"
            + "ULNPhK1fB9LYWCfbFRbM086NaxdTQX8VnZAfFEOx6bhdj2WjGSglxgdxa0oQy2o1"
            + "odpbtKMEUWaqrQPBDYgeianvbum5U3Ycc5d9ynsDkycIOb6DxA87nWO8TjM_ZvcY"
            + "86sUDbfqYcXru2mp8i77yL11HMonkhrqQrQIaqfMlD91BG_J-z2k0DK_CSiqzmfE"
            + "jmisOk4R_sxU41-E7J-gz9IJ9JLZvxAfkWWxnL808PuNZaoUlqVJrHd40Pyp8ROp"
            + "pDwD-3oiylJ5wkepVNkI7ZXVdFctUTmCY1CnD_KVDY7bHscvruZNE6Z6w3379ser"
            + "eDCvnV4VrZC7uQe3M_GTgvE4Fi5R1g7c9fnycimFKxbdEbPYo7JrEZwvvorrvmwJ"
            + "45D32t6l3_cn_vE_iclmbmzi7d3o7ALJmtd1G121sjqzE2jNqlIlvLetOuuY07lL"
            + "3vrBUkOqXf-L8wxcMk_qCPbeor_TScMmtNyR6PGsCUvxa3OwvK-TZD7NkfLUckFg"
            + "HRPehV8YzJW3vwFhgiDA";
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
              "Startpage"
              "DuckDuckGo"
            ];

            engines = {
              NixPackages = {
                definedAliases = ["@nixos" "@np"];
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

              "${defaultEngine}" = {
                definedAliases = ["@searx" "@sx"];
                iconUpdateURL =
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
                iconUpdateURL = "https://support.startpage.com/favicon.ico";
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

          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            skip-redirect
            ublock-origin
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
              + ''"unified-extensions-area":["skipredirect_sblask-browser-action"]''
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
          };

          extraConfig = let
            betterfox = builtins.fetchTarball {
              url = "https://github.com/yokoffing/Betterfox/archive/refs/tags/133.0.tar.gz";
              sha256 = "sha256:108slz69gpdki9y0z1vnxh1n48bfdadvdyck4366n67qvvkdmvsj";
            };
          in ''
            ${builtins.readFile "${betterfox}/user.js"}

            /****************************************************************************
             * START: MY OVERRIDES                                                      *
            ****************************************************************************/
            // visit https://github.com/yokoffing/Betterfox/wiki/Common-Overrides
            // visit https://github.com/yokoffing/Betterfox/wiki/Optional-Hardening
            // Enter your personal overrides below this line:

            // WORKAROUND: switch to 'Standard' tracking protection
            // to avoid issues related to 'Strict' ETP
            user_pref("browser.contentblocking.category", "standard");

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

            // PREF: enforce DNS-over-HTTPS (DoH)
            user_pref("network.trr.mode", 3);
            // PREF: set DoH provider (HaGeZi Pro + TIF)
            user_pref("network.trr.uri", "https://dns.dnswarden.com/00000000000000000000018");

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
