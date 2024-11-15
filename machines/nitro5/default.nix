{hostName, ...}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  fonts.fontconfig.subpixel.rgba = "rgb";
  time.timeZone = "Asia/Kathmandu";

  tgap.system = {
    boot = {
      secureBoot.enable = false;
      encrypted-btrfs.enable = true;
    };

    laptop = {
      enable = true;
      model = "Acer Nitro AN515-51";
    };

    network = {
      inherit hostName;
      enable = true;
      nameservers = ["9.9.9.9"];
      interfaces = ["enp7s0f1" "wlp0s20f3"];
      wifiRandMacAddress = false;
    };
  };
}
