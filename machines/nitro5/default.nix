{hostName, ...}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

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
      enable = true;
      inherit hostName;
      nameservers = ["9.9.9.9"];
      interfaces = ["enp7s0f1" "wlp0s20f3"];
      wifiRandMacAddress = false;
    };
  };
}
