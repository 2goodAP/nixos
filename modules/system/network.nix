{
  config,
  lib,
  ...
}: {
  options.tgap.system = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    bluetooth.enable = mkEnableOption "Whether or not to enable bluetooth-related services.";

    network = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether or not to enable networking services.";
      };

      hostName = mkOption {
        type = types.str;
        description = "The hostname of the device.";
      };

      nameservers = mkOption {
        type = types.listOf types.str;
        description = "The list of nameservers.";
      };

      interfaces = mkOption {
        type = types.listOf types.str;
        description = "The network interface chips present in the laptop.";
      };

      wifiRandMacAddress = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable MAC address randomization of a Wi-Fi device during scanning.";
      };
    };
  };

  config = let
    cfg = config.tgap.system;
    inherit (lib) mkIf mkMerge optionalAttrs;
  in
    mkMerge [
      (mkIf cfg.bluetooth.enable {
        hardware = {
          bluetooth.enable = true;
          xpadneo.enable = true;
        };
      })

      (mkIf cfg.network.enable {
        networking = {
          inherit (cfg.network) hostName nameservers;
          nftables.enable = true;

          networkmanager = {
            enable = true;
            enableStrongSwan = true;
            insertNameservers = cfg.network.nameservers;
            wifi.scanRandMacAddress = cfg.network.wifiRandMacAddress;
          };

          # Configure the firewall.
          firewall =
            {enable = true;}
            // (let
              localsendPort = 53317;
            in
              optionalAttrs cfg.programs.iosTools.enable {
                allowedTCPPorts = [localsendPort];
                allowedUDPPorts = [localsendPort];
              });
        };

        # Enable NTP.
        services = {
          ntp.enable = true;
          timesyncd.enable = true;
        };

        # Enable systemd-networkd.
        systemd.network = {
          enable = true;

          wait-online = {
            anyInterface = true;
            extraArgs = builtins.map (iface: "--interface=${iface}") cfg.network.interfaces;
          };
        };
      })
    ];
}
