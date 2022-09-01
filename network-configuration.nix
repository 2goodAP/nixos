# Network configurations for the various nixos profiles.

{ pkgs, ... }:

{
  networking = {
    hostName = "nixosbox";
    nameservers = [ "1.1.1.1" "9.9.9.9" ];

    networkmanager = {
      enable = true;
      enableStrongSwan = true;
      firewallBackend = "nftables";
      insertNameservers = [ "1.1.1.1" "9.9.9.9" ];
    };

    # Configure the firewall.
    firewall = {
      enable = true;
      package = pkgs.iptables-nftables-compat;
    };

    # Configure network proxy if necessary.
    #proxy = {
    #  default = "http://user:password@proxy:port/";
    #  noProxy = "127.0.0.1,localhost,internal.domain";
    #};
  };

  
  # Enable systemd-networkd.
  systemd.network = {
    enable = true;

    wait-online = {
      anyInterface = true;
      extraArgs = [ "--interface=wlp0s20f3" "--interface=enp7s0f1" ];
    };
  };
}
