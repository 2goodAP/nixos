{ config, lib, ... }:

let
  cfg = config.laptop.loader;
  inherit (lib) mkIf mkOption types;
in {
  options.laptop.loader = {
    enable = mkOption {
      description = "Whether or not to enable GRUB.";
      type = types.bool;
      default = true;
    };

    enableFullEncrypt = mkOption {
      description = "Whether or not to enable full disk encryption with encrypted /boot.";
      type = types.bool;
      default = true;
    };

    espMountPoint = mkOption {
      description = "The mount point of the ESP.";
      type = types.str;
      default = "/boot";
    };
  };

  config = mkIf cfg.enable {
    boot.loader = {
      efi = {
        canTouchEfiVariables = true;
        inherit (cfg) efiSysMountPoint;
      };

      grub = {
        enable = true;
        efiSupport = true;
        devices = [ "nodev" ];
        extraGrubInstallArgs = [ "--bootloader-id=GRUB" ];
        inherit (cfg) enableFullEncrypt espMountPoint;
      };
    };
  };
}
