{ config, pkgs, lib, ... }:

let
  cfg = config.machine.network;
  inherit (lib) mkIf mkOption types;
in {
  options.machine.network = {
    enable = mkOption {
      description = "Whether or not to enable networking services.";
      type = types.bool;
      default = true;
    };

    hostName = mkOption {
      description = "The hostname of the laptop.";
      type = types.str;
    };

    nameservers = mkOption {
      description = "The list of nameservers.";
      type = types.listOf types.str;
    };

    interfaces = mkOption {
      description = "The network interface chips present in the laptop.";
      type = types.listOf types.str;
    };
  };


  config = mkIf cfg.enable {
    networking = {
      inherit (cfg) hostName nameservers;

      networkmanager = {
        enable = true;
        enableStrongSwan = true;
        firewallBackend = "nftables";
        insertNameservers = cfg.nameservers;
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
