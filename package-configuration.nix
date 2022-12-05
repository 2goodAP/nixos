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

    settings = {
      substituters = [
        "https://app.cachix.org/cache/nixpkgs-wayland"
      ];
      trusted-public-keys = [
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs = {
    # Allow un-free (propriatery) and broken packages.
    config.allowUnfree = true;

    # Override packages using overlays.
    overlays = [
      # Emacs
      (import (builtins.fetchGit {
        url = "https://github.com/nix-community/emacs-overlay.git";
        ref = "master";
        rev = "acbbcb781724648f206068e230a7a5f77fba510c";
      }))

      # Wayland
      (import "${
        builtins.fetchGit {
          url = "https://github.com/nix-community/nixpkgs-wayland.git";
          ref = "master";
          rev = "7a42bdbb71bed152dc0fccb696b988985ecb412f";
        }
      }/overlay.nix")

      # Local
      (import ./overlays/fonts.nix)
      (import ./overlays/nbfc-linux.nix)
      (import ./overlays/neovim.nix)
      (import ./overlays/swaylock-effects.nix)
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
      emacsPgtkNativeComp
      git
      jq
      neovim
      (python39.withPackages (pks: with pks; [black mypy pylint pynvim]))
      (python310.withPackages (pks: with pks; [black mypy pylint pynvim]))
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
      basePackages = with pkgs; [
        android-file-transfer
        libimobiledevice
        ifuse

        firefox
        gimp
        keepassxc
        libreoffice-fresh
        nextcloud-client
        speedcrunch
        transmission
        zathura
      ];
      userPackages =
        basePackages
        ++ (with pkgs; [
          ungoogled-chromium
          zoom-us
        ]);
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
        packages = userPackages;
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
        packages = userPackages ++ (with pkgs; [openvpn insomnia]);
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
          basePackages
          ++ (with pkgs; [
            gamemode
            mangohud
            lutris
            unigine-heaven
            winetricks
            wineWowPackages.stagingFull
          ]);
        initialPassword = "NixOS-justagamer.";
      };
    };
  };
}
