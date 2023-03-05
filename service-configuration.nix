# Service configurations for the various nixos profiles.
{pkgs, ...}: {
  hardware = {
    bluetooth.enable = true;
    xpadneo.enable = true;
  };

  networking = {
    hostName = "nixosbox";
    nameservers = ["1.1.1.1" "9.9.9.9"];

    networkmanager = {
      enable = true;
      enableStrongSwan = true;
      firewallBackend = "nftables";
      insertNameservers = ["1.1.1.1" "9.9.9.9"];
      wifi.scanRandMacAddress = false;
    };

    firewall = {
      enable = true;
      package = pkgs.iptables-nftables-compat;
    };

    #proxy = {
    #  default = "http://user:password@proxy:port/";
    #  noProxy = "127.0.0.1,localhost,internal.domain";
    #};
  };

  programs = {
    bash.vteIntegration = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    light.enable = true;

    zsh = {
      enable = true;
      vteIntegration = true;
      autosuggestions.enable = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = ["main" "brackets" "pattern"];
      };
      promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      shellInit = "source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh";
    };
  };

  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = true;
  };

  services = {
    ntp.enable = true;
    timesyncd.enable = true;
    openssh.enable = true;
    printing.enable = true;
    tlp.enable = true;
    udev.packages = [pkgs.qmk-udev-rules];
    usbmuxd.enable = true;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;
    };

    undervolt = {
      enable = true;
      temp = 95;
      coreOffset = -150;
      uncoreOffset = -150;
    };
  };

  systemd = {
    # systemd-networkd.
    network = {
      enable = true;

      wait-online = {
        anyInterface = true;
        extraArgs = ["--interface=wlp0s20f3" "--interface=enp7s0f1"];
      };
    };

    services.nbfc_service = {
      enable = true;
      description = "NoteBook FanControl service";
      serviceConfig.Type = "simple";
      path = [pkgs.kmod];
      script = "${pkgs.nbfc-linux}/bin/nbfc_service";
      wantedBy = ["multi-user.target"];
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
      enableNvidia = true;
      storageDriver = "overlay2";
      rootless.enable = true;
    };

    virtualbox = {
      guest.enable = false;
      host.enable = true;
    };
  };
}
