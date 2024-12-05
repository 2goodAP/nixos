{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    audio = {
      enable = mkEnableOption "audio-related services" // {default = true;};
      simultOutput = {
        enable = mkEnableOption "simultaneous output sink";

        name = mkOption {
          type = types.str;
          description = "Name of the null sink used for simultaneous output.";
          default = "simultaneous-null-sink";
        };
      };
    };
  };

  config = let
    cfg = config.tgap.system.audio;
    inherit (lib) mkIf mkMerge;
  in
    mkIf cfg.enable (mkMerge [
      {
        services.pipewire = {
          enable = true;
          jack.enable = true;
          pulse.enable = true;
          alsa = {
            enable = true;
            support32Bit = true;
          };
        };
      }

      (mkIf cfg.simultOutput.enable {
        services = {
          pipewire = {
            extraConfig = let
              quant = 96;
              rate = 48000;
            in {
              pipewire = {
                "91-simultaneous-null-sink" = {
                  "context.objects" = [
                    {
                      factory = "adapter";
                      args = {
                        "factory.name" = "support.null-audio-sink";
                        "node.name" = "${cfg.simultOutput.name}";
                        "node.description" = "Virtual Simultaneous Output";
                        "media.class" = "Audio/Sink";
                        "object.linger" = true;
                        "audio.position" = "FL,FR,RL,RR";
                      };
                    }
                  ];
                };

                "92-low-latency" = {
                  "context.properties" = {
                    "default.clock.rate" = rate;
                    "default.clock.quantum" = quant;
                    "default.clock.min-quantum" = 32;
                    "default.clock.max-quantum" = quant;
                  };
                };
              };

              pipewire-pulse."92-low-latency" = let
                squant = builtins.toString quant;
                srate = builtins.toString rate;
              in {
                context.modules = [
                  {
                    name = "libpipewire-module-protocol-pulse";
                    args = {
                      pulse.min.req = "32/${srate}";
                      pulse.default.req = "${squant}/${srate}";
                      pulse.max.req = "${squant}/${srate}";
                      pulse.min.quantum = "32/${srate}";
                      pulse.max.quantum = "${squant}/${srate}";
                    };
                  }
                ];

                stream.properties = {
                  node.latency = "${squant}/${srate}";
                  resample.quality = 1;
                };
              };
            };

            wireplumber = let
              wpLuaComponent = "link-to-null-sink";
            in {
              configPackages = [
                (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/91-user-scripts.conf" ''
                  {
                    wireplumber.components = [
                      {
                        name = linking/${wpLuaComponent}.lua
                        type = script/lua
                        provides = custom.${wpLuaComponent}
                      }
                    ],
                    wireplumber.profiles = {
                      main = {
                        custom.${wpLuaComponent} = required
                      }
                    }
                  }
                '')
              ];

              extraScripts = {
                "linking/${wpLuaComponent}.lua" = let
                  interests = ''
                    EventInterest({
                      Constraint({ "event.type", "equals", "%event%" }),
                      Constraint({ "item.node.type", "equals", "device" }),
                      Constraint({ "media.class", "equals", "Audio/Sink" }),
                      Constraint({ "device.api", "equals", "alsa" }),
                    }),
                    EventInterest({
                      Constraint({ "event.type", "equals", "%event%" }),
                      Constraint({ "item.node.type", "equals", "device" }),
                      Constraint({ "media.class", "equals", "Audio/Sink" }),
                      Constraint({ "device.api", "matches", "bluez*" }),
                    }),
                  '';
                  inherit (builtins) replaceStrings;
                in ''
                  Lutils = require("linking-utils")
                  Log_topic = Log.open_topic("s-linking")

                  SimpleEventHook({
                    name = "linking/push-select-target",
                    before = "linking/rescan-trigger",
                    after = "linking/session-item-added",
                    interests = {
                      ${replaceStrings ["%event%"] ["session-item-added"] interests}
                    },
                    execute = function(event)
                      local source = event:get_source()
                      local si = event:get_subject()

                      Log_topic:info(
                        "Pushing event 'select-target' for session-item " .. si.properties["node.description"]
                      )

                      -- Push the `select-target` event for automatic linking
                      source:call("push-event", "select-target", si, nil)
                    end,
                  }):register()

                  SimpleEventHook({
                    name = "linking/find-simultaneous-target",
                    before = "linking/find-defined-target",
                    interests = {
                      ${replaceStrings ["%event%"] ["select-target"] interests}
                    },
                    execute = function(event)
                      local _, om, si, si_props, _, target = Lutils:unwrap_select_target_event(event)

                      -- Bypass the hook if the target is already picked up
                      if target then
                        return
                      end

                      Log_topic:info(si, "in find-simultaneous-target")

                      target = om:lookup({
                        type = "SiLinkable",
                        Constraint({ "item.node.type", "equals", "device" }),
                        Constraint({ "media.class", "equals", "Audio/Sink" }),
                        Constraint({ "node.name", "equals", "${cfg.simultOutput.name}" }),
                      })

                      if not target or not Lutils.canLink(si_props, target) then
                        -- Bypass the hook if there is nothing to link to
                        Log_topic:warning("Failed to locate linkable target sink: ${cfg.simultOutput.name}")
                        return
                      end

                      Log_topic:info("Successfully located linkable target sink: ${cfg.simultOutput.name}")

                      event:set_data("target", target)
                    end,
                  }):register()
                '';
              };
            };
          };
        };
      })
    ]);
}
