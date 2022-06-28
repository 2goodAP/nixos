# Package configurations for the various nixos profiles.

{ config, pkgs, options, ... }:

{
  # Append "nixpkgs-overlays" to existing NIX_PATH.
  nix = {
    nixPath = options.nix.nixPath.default ++
              [ "nixpkgs-overlays=/etc/nixos/overlays-compat/" ];

    package = pkgs.nixUnstable;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };


  nixpkgs = {
    # Allow un-free (propriatery) and broken packages.
    config = {
      allowBroken = false;
      allowUnfree = true;
    };

    # Override packages using overlays.
    overlays = [
      (self: super: {
				neovim = super.neovim.override {
				  withNodeJs = true;
        };
      })
      (self: super: {
        sddm = super.sddm.overrideAttrs (oldAttrs: {
          name = "sddm-git";
          version = "0.19.0.e67307e";

          src = super.fetchgit {
            url = "https://github.com/sddm/sddm";
            rev = "e67307e4103a8606d57a0c2fd48a378e40fcef06";
            sha256 = "1rcs8mkykvhlygiv6fs07q67q9bigywi5hz0m4g66fjrbsbyh7gp";
          };

          patches = [];
        });
      })
    ];
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = let
    pkgsUnstable = import <nixos-unstable> {
      # Propagate nixpkgs.config into the "pkgsUnstable" alias.
      config = config.nixpkgs.config;
    };
  in
  (with pkgs; [
    gparted
    gptfdisk
    ntfs3g

    acpi
    brightnessctl
    tlp

    zsh
    zsh-history-substring-search
    zsh-powerlevel10k

    (python39.withPackages (pks: with pks; [ black mypy pylint pynvim ]))
    (python310.withPackages (pks: with pks; [ black mypy pylint pynvim ]))

    cmus
    conda
    docker-compose
    git
		neovim
    ranger
    tmux
    wget

    p7zip
    unrar
    unzip
    zip
  ]);


  # Allow automatic upgrades.
  system.autoUpgrade = {
    enable = true;
    channel = https://channels.nixos.org/nixos-22.05;
  };
}
