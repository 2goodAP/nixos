# Channul update is andatory for getting new packages.
sudo nix-channel --update

sudo nixos-rebuild \
    -I nixos-config=$HOME/.nixos/configuration.nix \
    -I nixpkgs-overlays=$HOME/.nixos/overlays \
    "$@"
