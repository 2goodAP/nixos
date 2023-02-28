sudo nixos-rebuild \
    -I nixos-config=$HOME/.nixos/configuration.nix \
    -I nixpkgs-overlays=$HOME/.nixos/overlays \
    "$@"
