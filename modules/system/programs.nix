{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "Whether or not to install common system-wide programs.";
    androidTools.enable = mkEnableOption "Whether or not enable Android helper packages.";
    cms.enable = mkEnableOption "Whether to enable color management systems.";
    iosTools.enable = mkEnableOption "Whether or not enable iOS helper packages.";
    qmk.enable = mkEnableOption "Whether or not enable qmk and related udev packages.";
    virtualisation.enable = mkEnableOption "Whether or not to enable Docker and VirtualBox.";

    defaultShell = mkOption {
      type = types.enum ["bash" "nushell"];
      default = "nushell";
      description = "The default shell assigned to user accounts.";
    };
  };

  config = let
    cfg = config.tgap.system.programs;
    nvidia = builtins.elem "nvidia" config.services.xserver.videoDrivers;
    inherit (lib) getExe mkIf mkMerge optionals;
  in
    mkIf cfg.enable (mkMerge [
      {
        users.defaultUserShell =
          if (cfg.defaultShell == "nushell")
          then pkgs.nushell
          else pkgs.bashInteractive;

        # List packages installed in system profile.
        environment.systemPackages =
          [config.boot.kernelPackages.turbostat]
          ++ (with pkgs; [
            # Hardware
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
          gnupg.agent.enable = true;

          bash = {
            blesh.enable = true;
            vteIntegration = true;
          };

          git = {
            enable = true;
            lfs.enable = true;
            config = {
              core.pager = "${getExe pkgs.delta}";
              delta.navigate = true;
              diff.colorMoved = "default";
              init.defaultBranch = "main";
              interactive.diffFilter = "${getExe pkgs.delta} --color-only";
              merge.conflictstyle = "diff3";
              pull.rebase = false;
              push.autoSetupRemote = true;
            };
          };
        };

        services = {
          atuin.enable = true;
          openssh.enable = true;
          udev.packages = optionals cfg.qmk.enable [pkgs.qmk-udev-rules];
        };
      }

      (mkIf cfg.cms.enable {
        environment.systemPackages = optionals nvidia [pkgs.argyllcms];
        services.colord.enable = !nvidia;
      })

      (mkIf cfg.iosTools.enable {
        services.usbmuxd.enable = true;
      })

      (mkIf cfg.virtualisation.enable {
        hardware.nvidia-container-toolkit.enable = nvidia;

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
