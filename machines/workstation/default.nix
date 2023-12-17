{hostName, ...}: {
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  time.timeZone = "Asia/Kathmandu";

  environment.systemPackages = with pkgs; [
    hpl
    mprime
  ];

  tgap.system = {
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
      vkDeviceID = "2782";
    };

    network = {
      enable = true;
      inherit hostName;
      nameservers = ["9.9.9.9"];
      interfaces = ["enp4s0" "wlo1"];
    };
  };
}
