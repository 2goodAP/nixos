{sysName, ...}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  fonts.fontconfig.subpixel.rgba = "rgb";
  time.timeZone = "Asia/Kathmandu";

  tgap.system = {
    audio.simultOutput.enable = true;

    boot = {
      secureBoot.enable = true;
      encrypted-btrfs = {
        enable = true;
        swap.partlabel = "LinuxSwapPart";
        root = {
          partlabel = "LinuxPriDataPart";
          extraPartlabels = ["LinuxSecDataPart"];
        };
      };
    };

    network = {
      enable = true;
      hostName = "${sysName}-nix";
      interfaces = ["enp4s0" "wlo1"];
    };

    programs = {
      qmk.enable = true;
      virtualization.enable = true;
    };
  };
}
