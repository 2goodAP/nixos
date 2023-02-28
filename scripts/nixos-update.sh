SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Channul update is mandatory for fetching new packages.
sudo nix-channel --update
source "$SCRIPT_DIR/nixos-rebuild.sh"
