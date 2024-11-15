{hostName, ...}: {
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
        root = {
          partlabel = "LinuxPriDataPart";
          extraPartlabels = ["LinuxSecDataPart"];
        };
      };
    };

    desktop.gaming = {
      enable = true;
      controllers = {
        dualsense.enable = true;
        xbone.enable = true;
      };
    };

    network = {
      inherit hostName;
      enable = true;
      nameservers = ["9.9.9.9"];
      interfaces = ["enp4s0" "wlo1"];
    };
  };
}
