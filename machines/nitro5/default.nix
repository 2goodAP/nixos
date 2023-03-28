{hostName, ...}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  tgap.system = {
    boot.type = "encrypted-boot-btrfs";
    laptop = {
      enable = true;
      model = "Acer Nitro AN515-51";
    };

    network = {
      enable = true;
      inherit hostName;
      nameservers = ["1.1.1.1" "9.9.9.9"];
      interfaces = ["enp7s0f1" "wlp0s20f3"];
      wifiRandMacAddress = false;
    };
  };

  time.timeZone = "Asia/Kathmandu";
}
