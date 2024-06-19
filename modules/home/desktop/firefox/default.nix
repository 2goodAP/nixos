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
            + "eJx1WEuP67oN_jXNxrhB21ug6CKrAt3eAr17g5YYW8ey6KNHEs-vL-lHTMdzFuM"
            + "ZfZQovkmNgYwtRYfp1mLACP7iIbQFWrxByXTxZMDjDcNFloaG0WPGmy2ml5-WLm"
            + "7gzfUY6TXd_owFLwPmjuztv3_8789LgjsmhGi6218vucMBb8kJj0vEVHxONYU64"
            + "LPO0CynLbmaaeQfGG8EvLxSbC_LqTrlya-SGQwZYw3etWHgv2__AZ_wAvYBwaCt"
            + "12sX9GfBONUu1NllZrCALtxdcJm5mkjeL_cvx0Qss9hmYk4eTV7IHeUep3SzeAe"
            + "W_2JdgsbzdRhaF9iM_2qhretExoGvBrQO_vL3f0MIkCph7B5Y13fnMQk89tXgYq"
            + "SoMdaz4m-VMkW9OYChYKGuXZZl6ut69RkvG-ed_NT1w1mkNEO5YRdhXk80Y3M4k"
            + "a1r253_LOvVGHO1qLiYcYx4x4hs1JURWyslBllN4wRfsKd9OPakumLC8WNZzdGS"
            + "mNH8ewU5ABiSr3Aq0Ts8SApd6OiuIYv4xc6vh5KcmdcpQ3bMhTjKoiC2rdhJ4mB"
            + "HIenDyLI6q7a-g7l6Igi40xZ3DDAyB_7K6YF-uFGMte_K7PrpIPPfXkrHu40kF2"
            + "6mZqls7iAPnA96W0SsEt3zEyJW1kWOOom_xer36ELvwOgD06TUaDm0odl8RBYbj"
            + "O26ZBqyc2nY1kQ2IlhlMIZaVnX0MEn4pV1cTRmInZxUfAycJVFi3ZnZzG_h2pGs"
            + "1T7qoIkgn1WGDjg44-L7BcDXO8KYa7o6WtdusM0uqQugBPjhUkc7kdMgYo4Qkmc"
            + "e2iWempTxGrfruE6BGSFsS_rqnN4_PIfGayCMm_nCBLDbh-yUUOcMjcglKaMSS6"
            + "CIIymzjqw_tC5t-cl5thYfdecbPGfOTlou_v7YIbfG0nB2P9YLI-XMhZPYhYQqE"
            + "paTw5Tc0YBc60xJ6TpOXOA3sxmwdpLIGgqn2haso_utI48nfGEtwVnJZ0MzxDxK"
            + "G1G3ZeonysTO7cVHm9WyaJ9MB-WwWaGrrvkQMxN0RPrE0zWTXnOXe0GwUdJa7-p"
            + "dQ9SnT_BnoaNxBExUojmjI5o5Z44w97c0G-YDpunDEE_y9wgD-LE7yGaLxaC99h"
            + "VgOASw5OroPOV9V4CH5OS-KZZmanHYkmJEjLk0OprnxsDHeynvT2wUaQJzUEDW5"
            + "0CNhRNJc_SsfOLw19iTXq6nwOFZpSlQmKQ07rphH4-hvECnuxZ4S4g39_RjvI5P"
            + "bS0uESZr2dOjlQRVvB5ctL0LZatK4p6BG8pB4zIMfjqUn73CLPHQlbxX3UOS9u2"
            + "1pS0hLxiOk8ScvvP9ldy89f2Yne4BEF_uoTtxw1FsYBj3wiun14alB4bQfq7P5p"
            + "zRg91n5GRfKW8S0LqdmQ7vPUk524zDrV3miOnYyR8OghQAddSStIaqK40yvYX8E"
            + "f9b2_4ePWujaCcNFO2gL-ZpoMBuUOF49870Ufc6DK6k3eKtlNWteXHv3RVZeqkW"
            + "eO2uJ2FX_CDMip2EX3EugOQh6mjo1vvWNtoWLbYLzMFR0awUtmnTs7aQVOfyOAx"
            + "TtdX2ubZ9DLzLjpIw_orGrTD_iiac2YLfkLm5Q5wqsV5ySqKv31aSEnLdS3fmFz"
            + "i3k7YuO7R9HMJpAB64LYVfSP0md5A6bjff7LDvUcK9jKdidxMOwLMbbpOPZAvwe"
            + "CcRnXDW8-2wjcatmqMM1uH1SOfihZh5HN1m0tFKxd43jfxMkQ69Up28lDDpDBul"
            + "Iii3z-vrLO4u9ehkDmtAWZWHOsOW4AFWhrUtIVjYQdgpCaZxq1g_n5zf2tIzcAz"
            + "sBTrlwAKfwj0CR2jV8Bif9IDJBrUun_ySuAfCNlntHYEK18mjl3gOMT1xHbt7eu"
            + "7vrNKUkMuWQ2LLwKPj8pj7JuVSGTGW9PZ2QvY-F-3v0pPfuc7ykB-XcN-sXELia"
            + "Tt1-p0kA8zRaBOVj1b9Rt7vInCe65dEkdr2cIPMpnvv5ep64HwYW3ZpGRZOc5pt"
            + "rpetkq8cpteT_zTx5EVNhGJl2NcdayPNNtlNY53JXxQOJXTgYWHgl1L1nvvt4S3"
            + "2--__fKmHLv3gIeE4KAlyDr8VP5qGog2uV28_oiwPOvH3R-Q9wfuOB66gTZJzvD"
            + "o1iXCVehyfuwKcbbnAJysu8LFF539s7_r9_xOjLzxWpJskwuu6rq4dV2GeGrHmg"
            + "uN5IHsPId9vN-BNYfvS9kxQnCRcl8WZtt6SThSCevmHzzPyY-NETujvtQt3OlFY"
            + "hJoHDNOfKXF-V9YleuY7SDqf9kjbqrkrMI2z-cJPDS6qt_8DrC4ytQ==";
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

          extensions = with config.nur.repos.rycee.firefox-addons; [
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
            customDNS = "https://sky.rethinkdns.com/1:-N8BGADgfwP_6dv_8t-_8NARVnMhAGF6ANg=";
          in ''
            ${builtins.readFile ./arkenfox-user.js}

            // START User Overrides
            user_pref("_user.js.parrot", "START: user overrides");

            // Set DNS over HTTPS (Rethink DNS).
            user_pref("network.trr.mode", 3);
            user_pref("network.trr.custom_uri", "${customDNS}");
            user_pref("network.trr.uri", "${customDNS}");

            // Leave IPv6 enabled.
            user_pref("network.dns.disableIPv6", false);

            // Use search engine URL as the browser startup homepage.
            user_pref("browser.startup.page", 1);
            user_pref("browser.startup.homepage", "${searxBaseURL}/preferences${searxPrefs}");

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

            // Disable fingerprinting resist to fix timezones.
            user_pref("privacy.resistFingerprinting", false);
            user_pref("privacy.resistFingerprinting.pbmode", false);

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

            // END User Overrides
            user_pref("_user.js.parrot", "SUCCESS: user overrides");
          '';
        };
      };
    };
  }
