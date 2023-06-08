{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.network = let
    inherit (lib) mkOption types;
  in {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether or not to enable networking services.";
    };

    hostName = mkOption {
      type = types.str;
      description = "The hostname of the laptop.";
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

  config = let
    cfg = config.tgap.system.network;
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      networking = {
        inherit (cfg) hostName nameservers;

        networkmanager = {
          enable = true;
          enableStrongSwan = true;
          firewallBackend = "nftables";
          insertNameservers = cfg.nameservers;
          wifi.scanRandMacAddress = cfg.wifiRandMacAddress;
        };

        # Configure the firewall.
        firewall = {
          enable = true;
          package = pkgs.iptables-nftables-compat;
        };
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
          extraArgs = builtins.map (iface: "--interface=${iface}") cfg.interfaces;
        };
      };
    };
}
