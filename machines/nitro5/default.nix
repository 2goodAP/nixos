{sysName, ...}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  boot.loader.timeout = 1;
  fonts.fontconfig.subpixel.rgba = "rgb";
  time.timeZone = "Asia/Kathmandu";

  tgap.system = {
    boot = {
      secureBoot.enable = false;
      encrypted-btrfs = {
        enable = true;
        swap.partlabel = "LinuxSwapPart";
      };
    };

    laptop = {
      enable = true;
      model = "Acer Nitro AN515-51";
    };

    network = {
      enable = true;
      hostName = "${sysName}-nix";
      interfaces = ["enp7s0f1" "wlp0s20f3"];
    };

    programs = {
      qmk.enable = true;
      virtualization.enable = true;
    };
  };
}
