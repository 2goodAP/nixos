{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "common system-wide programs";
    androidTools.enable = mkEnableOption "Android helper packages";
    cms.enable = mkEnableOption "Whether to enable color management systems.";
    iosTools.enable = mkEnableOption "iOS helper packages";
    qmk.enable = mkEnableOption "qmk and related udev packages";
    virtualization.enable = mkEnableOption "Docker and VirtualBox";

    defaultShell = mkOption {
      type = types.enum ["bash" "nushell"];
      default = "nushell";
      description = "The default shell assigned to user accounts.";
    };
  };

  config = let
    cfg = config.tgap.system.programs;
    hasNvidia = builtins.elem "nvidia" config.services.xserver.videoDrivers;
    inherit (lib) mkIf mkMerge optionals;
  in
    mkIf cfg.enable (mkMerge [
      {
        users.defaultUserShell = pkgs.bashInteractive;

        # List packages installed in system profile.
        environment.systemPackages =
          [config.boot.kernelPackages.turbostat]
          ++ (with pkgs; [
            # Hardware
            btrfs-progs
            e2fsprogs
            exfatprogs
            gptfdisk
            ntfs3g
            parted
            s-tui

            # Programs
            delta
            entr
            file
            git-filter-repo
            git-subrepo
            jc
            p7zip
            pciutils
            psmisc
            pzip
            rename
            unrar-free
            util-linux
            wget
            yq-go
          ])
          ++ optionals cfg.androidTools.enable (with pkgs; [
            android-file-transfer
            android-tools
          ])
          ++ optionals cfg.iosTools.enable (with pkgs; [
            ifuse
            libimobiledevice
          ])
          ++ optionals cfg.qmk.enable [pkgs.qmk];

        programs = {
          gnupg.agent = {
            enable = true;
            settings.no-allow-external-cache = "";
          };

          bash = {
            blesh.enable = true;
            vteIntegration = true;
          };
        };

        services = {
          atuin.enable = true;
          openssh.enable = true;
          udev.packages = optionals cfg.qmk.enable [pkgs.qmk-udev-rules];
        };
      }

      (mkIf cfg.cms.enable {
        environment.systemPackages = optionals hasNvidia [pkgs.argyllcms];
        services.colord.enable = !hasNvidia;
      })

      (mkIf cfg.iosTools.enable {
        services.usbmuxd.enable = true;
      })

      (mkIf cfg.virtualization.enable {
        hardware.nvidia-container-toolkit.enable = hasNvidia;

        virtualisation = {
          docker = {
            enable = true;
            enableOnBoot = false;
            storageDriver = "overlay2";
            rootless.enable = true;
          };

          virtualbox = {
            guest.enable = true;

            host = {
              enable = true;
              enableExtensionPack = true;
            };
          };
        };
      })
    ]);
}
