{hostName, ...}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  tgap.system = {
    boot.type = "encrypted-boot-btrfs";

    network = {
      enable = true;
      inherit hostName;
      nameservers = ["1.1.1.1" "9.9.9.9"];
      interfaces = ["enp4s0" "wlo1"];
    };
  };

  time.timeZone = "Asia/Kathmandu";
}
