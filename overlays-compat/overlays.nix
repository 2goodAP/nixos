# A "compatibility" overlay which loads all overlays defined in the system
# NixOS configuration, allowing various Nix tools to load those overlays.

self: super:
with super.lib;
let
  # Load the system config and get the `nixpkgs.overlays` option
  overlays = (import <nixpkgs/nixos> {}).config.nixpkgs.overlays;
in
  # Apply all overlays to the input of the current "main" overlay
  foldl' (flip extends) (_: super) overlays self
