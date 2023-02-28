# Package configurations for the various nixos profiles.
{
  config,
  pkgs,
  options,
  ...
}: {
  # Append "nixpkgs-overlays" to existing NIX_PATH.
  nix = {
    package = pkgs.nixUnstable;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs = {
    # Allow un-free (propriatery) and broken packages.
    config.allowUnfree = true;

    # Override packages using overlays.
    overlays = [
      # Local
      (import ./overlays/fonts.nix)
      (import ./overlays/nbfc-linux.nix)
      (import ./overlays/neovim.nix)
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    etc."nbfc/nbfc.json" = {
      text = ''
        {"SelectedConfigId": "Acer Nitro AN515-51"}
      '';
      mode = "0644";
    };

    shells = [pkgs.bashInteractive pkgs.zsh];

    systemPackages = with pkgs; [
      # Hardware
      acpi
      gparted
      gptfdisk
      nbfc-linux
      ntfs3g
      pamixer
      pulseaudio
      qmk
      tlp

      # Shell
      zsh
      zsh-history-substring-search
      zsh-powerlevel10k

      # Programs
      busybox
      cmus
      conda
      docker-compose
      git
      jq
      neovim
      (python3.withPackages (pys: with pys; [black mypy pylint pynvim]))
      p7zip
      ranger
      unrar
      unzip
      tmux
      wget
      zip
    ];

    variables = {
      TERMINFO_DIRS = ["${pkgs.foot.terminfo}/share/terminfo"];
    };
  };

  # User and group configurations for the various nixos profiles.
  users = {
    defaultUserShell = pkgs.zsh;

    users = let
      userPackages = with pkgs; [
        android-file-transfer
        libimobiledevice
        ifuse

        ungoogled-chromium
        gimp
        keepassxc
        libreoffice-fresh
        nextcloud-client
        speedcrunch
        transmission
        zathura
      ];
    in {
      root = {
        isSystemUser = true;
        initialPassword = "NixOS-root.";
      };

      aashishp = {
        isNormalUser = true;
        extraGroups = [
          "audio"
          "cups"
          "disk"
          "docker"
          "networkmanager"
          "nixbld"
          "video"
          "wheel"
        ];
        packages =
          userPackages
          ++ (with pkgs; [
            firefox
            via
            zoom-us
          ]);
        initialPassword = "NixOS-aashishp.";
      };

      workerap = {
        isNormalUser = true;
        extraGroups = [
          "audio"
          "cups"
          "disk"
          "docker"
          "networkmanager"
          "nixbld"
          "video"
          "wheel"
        ];
        packages =
          userPackages
          ++ (with pkgs; [
            google-chrome
            openvpn
            zoom-us
          ])
          ++ [(import <nixos-22.05> {}).insomnia];
        initialPassword = "NixOS-workerap.";
      };

      justagamer = {
        isNormalUser = true;
        extraGroups = [
          "audio"
          "disk"
          "networkmanager"
          "video"
          "wheel"
        ];
        packages =
          userPackages
          ++ (with pkgs; [
            firefox
            gamemode
            lutris
            mangohud
            winetricks
            wineWowPackages.stagingFull
          ]);
        initialPassword = "NixOS-justagamer.";
      };
    };
  };
}
