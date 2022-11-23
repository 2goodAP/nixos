# Package configurations for the various nixos profiles.
{
  config,
  pkgs,
  options,
  ...
}: {
  # Append "nixpkgs-overlays" to existing NIX_PATH.
  nix = {
    nixPath =
      options.nix.nixPath.default
      ++ [
        "nixpkgs-overlays=$HOME/.nixos/overlays/"
      ];

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
      # Emacs
      (import (builtins.fetchGit {
        url = "https://github.com/nix-community/emacs-overlay.git";
        ref = "master";
        rev = "acbbcb781724648f206068e230a7a5f77fba510c";
      }))
      # Local
      (import ./overlays/caskaydia-cove-nerd-font.nix)
      (import ./overlays/fira-code-nerd-font.nix)
      (import ./overlays/nbfc-linux.nix)
      (import ./overlays/neovim.nix)
      (import ./overlays/noto-nerd-font.nix)
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

  # Allow automatic upgrades.
  system.autoUpgrade = {
    enable = true;
    channel = https://channels.nixos.org/nixos-unstable;
  };
}
