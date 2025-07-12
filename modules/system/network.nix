{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.network = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "networking services" // {default = true;};
    wifiRandMacAddress =
      mkEnableOption "MAC address randomization of a Wi-Fi device during scanning"
      // {default = true;};

    hostName = mkOption {
      type = types.str;
      description = "The hostname of the device.";
    };

    interfaces = mkOption {
      type = types.listOf types.str;
      description = "The network interface chips present in the machine.";
    };

    allowedPorts = mkOption {
      type = types.attrsOf types.port;
      description = "TCP/UDP ports to allow in the firewall.";
      default = {};
    };

    allowedPortRanges = mkOption {
      type = types.attrsOf (types.attrsOf types.port);
      description = "A range of TCP/UDP ports to allow in the firewall.";
      default = {};
    };

    nameservers = mkOption {
      type = types.listOf types.str;
      description = "IPv4 and IPv6 addresses of the DNS resolver.";
      default = [
        "9.9.9.9#dns.quad9.net"
        "149.112.112.112#dns.quad9.net"
        "2620:fe::fe#dns.quad9.net"
        "2620:fe::9#dns.quad9.net"
      ];
    };

    fallbackDns = mkOption {
      type = types.listOf types.str;
      description = "IPv4 and IPv6 addresses of the fallback DNS resolver.";
      default = [
        "1.1.1.2#security.cloudflare-dns.com"
        "1.0.0.2#security.cloudflare-dns.com"
        "2606:4700:4700::1112#security.cloudflare-dns.com"
        "2606:4700:4700::1002#security.cloudflare-dns.com"
      ];
    };
  };

  config = let
    cfg = config.tgap.system.network;
    inherit (lib) mapAttrsToList mkIf mkMerge;
  in
    mkMerge [
      (mkIf cfg.enable {
        networking = {
          inherit (cfg) hostName nameservers;
          nftables.enable = true;

          networkmanager = {
            enable = true;
            plugins = [pkgs.networkmanager-strongswan];
            wifi.scanRandMacAddress = cfg.wifiRandMacAddress;
          };

          # Configure the firewall.
          firewall = let
            allowedPorts = mapAttrsToList (_: value: value) cfg.allowedPorts;
            allowedPortRanges = mapAttrsToList (_: value: value) cfg.allowedPortRanges;
          in {
            enable = true;
            allowedTCPPorts = allowedPorts;
            allowedTCPPortRanges = allowedPortRanges;
            allowedUDPPorts = allowedPorts;
            allowedUDPPortRanges = allowedPortRanges;
          };
        };

        # Enable NTP.
        services = {
          ntp.enable = true;
          timesyncd.enable = true;

          resolved = {
            inherit (cfg) fallbackDns;
            enable = true;
            dnssec = "true";
            dnsovertls = "true";
          };
        };

        # Enable systemd-networkd.
        systemd.network = {
          enable = true;

          wait-online = {
            anyInterface = true;
            extraArgs = map (iface: "--interface=${iface}") cfg.interfaces;
          };
        };
      })
    ];
}
