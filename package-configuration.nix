# Package configurations for the various nixos profiles.

{ config, pkgs, options, ... }:

{
  # Append "nixpkgs-overlays" to existing NIX_PATH.
  nix = {
    nixPath = options.nix.nixPath.default ++ [
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
      (import ./overlays/big-bag-kbd-trix-xkb.nix)
      (import ./overlays/caskaydia-cove-nerd-font.nix)
      (import ./overlays/fira-code-nerd-font.nix)
      (import ./overlays/neovim.nix)
      (import ./overlays/noto-nerd-font.nix)
      (import ./overlays/swaylock-effects.nix)
    ];
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Hardware
    acpi
    gparted
    gptfdisk
    ntfs3g
    pamixer
    pulseaudio
    tlp

    # Shell
    zsh
    zsh-history-substring-search
    zsh-powerlevel10k

    # Programs
    big-bag-kbd-trix-xkb
    busybox
    cmus
    conda
    docker-compose
    git
    jq
		neovim
    (python39.withPackages (pks: with pks; [ black mypy pylint pynvim ]))
    (python310.withPackages (pks: with pks; [ black mypy pylint pynvim ]))
    p7zip
    ranger
    unrar
    unzip
    tmux
    wget
    zip
  ];


  # Allow automatic upgrades.
  system.autoUpgrade = {
    enable = true;
    channel = https://channels.nixos.org/nixos-unstable;
  };
}
