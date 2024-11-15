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
          default = "Simultaneous Output";
        };
      };
    };
  };

  config = let
    cfg = config.tgap.system.audio;
    inherit (lib) getExe getExe' mkIf mkMerge;
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
          pipewire.wireplumber = let
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
                      Constraint({ "node.name", "equals", "Simultaneous Output" }),
                    })

                    if not target or not Lutils.canLink(si_props, target) then
                      -- Bypass the hook if there is nothing to link to
                      Log_topic:warning("Failed to locate linkable target sink: Simultaneous Output")
                      return
                    end

                    Log_topic:info("Successfully located linkable target sink: Simultaneous Output")

                    event:set_data("target", target)
                  end,
                }):register()
              '';
            };
          };
        };

        systemd.user.services = let
          audioRequires = ["sound.target" "pipewire.socket"];

          virtSimultSink = pkgs.writeShellScript "virt-simult-sink" ''
            set -e

            # Create a new sink called ${cfg.simultOutput.name}
            # after deleting any existing sinks of the same name
            if ${getExe' pkgs.pipewire "pw-cli"} list-objects Node |
              ${getExe pkgs.ripgrep} -q 'node\.name.*${cfg.simultOutput.name}'
            then
              ${getExe' pkgs.pipewire "pw-cli"} destroy '${cfg.simultOutput.name}'
            fi
            ${getExe' pkgs.pipewire "pw-cli"} create-node adapter \
              '{ factory.name=support.null-audio-sink node.name="${cfg.simultOutput.name}" node.description="${cfg.simultOutput.name}" media.class=Audio/Sink object.linger=true audio.position=[FL FR RL RR] }'

            # Switch the default output to the new virtual sink
            ${getExe' pkgs.wireplumber "wpctl"} set-default $(
              ${getExe' pkgs.wireplumber "wpctl"} status |
              ${getExe pkgs.ripgrep} ' |[ *]*?(\d+)\. Simultaneous Output' -or '$1' |
              ${getExe pkgs.gawk} 'NF{$1=$1;print}'
            )

            set +e

            # Finish and return the code for success
            exit 0
          '';
        in {
          audio-virtual-simultaneous-sink = {
            description = "Create a virtual sink for simultaneous output.";
            after = audioRequires;
            requires = audioRequires;
            wantedBy = ["default.target"];

            serviceConfig = {
              ExecStart = "${virtSimultSink}";
              ExecStop = "${getExe' pkgs.pipewire "pw-cli"} destroy '${cfg.simultOutput.name}'";
              RemainAfterExit = true;
              Restart = "on-failure";
              Type = "oneshot";
            };
          };
        };
      })
    ]);
}
