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
        root.partlabel = "GameDataPart";
      };
    };

    desktop.gaming = {
      enable = true;
      gamescope.vkDevice = "8086:a780";
      steam.enable = true;
      controllers = {
        dualsense.enable = true;
        xbone.enable = true;
      };
    };

    network = {
      enable = true;
      hostName = "${sysName}-nix";
      interfaces = ["enp4s0" "wlo1"];
    };
  };
}
