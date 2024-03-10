{hostName, ...}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  time.timeZone = "Asia/Kathmandu";

  tgap.system = {
    desktop.gaming.enable = true;

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

    network = {
      enable = true;
      inherit hostName;
      nameservers = ["9.9.9.9"];
      interfaces = ["enp4s0" "wlo1"];
    };
  };
}
