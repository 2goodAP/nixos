{
  hostName,
  mkHomeSettings,
  ...
}: {
  config,
  lib,
  ...
}: {
  imports = [
    ./hardware.nix
    ../common.nix
  ];

  time.timeZone = "Asia/Kathmandu";

  users.users = {
    root = {
      isSystemUser = true;
      initialPassword = "NixOS-root.";
      createHome = true;
    };

    twogoodap = {
      isNormalUser = true;
      initialPassword = "NixOS-twogoodap.";
      createHome = true;
      extraGroups = [
        "audio"
        "cups"
        "disk"
        "docker"
        "networkmanager"
        "video"
        "wheel"
      ];
    };

    workerap = {
      isNormalUser = true;
      initialPassword = "NixOS-workerap.";
      createHome = true;
      extraGroups = [
        "audio"
        "cups"
        "disk"
        "docker"
        "networkmanager"
        "video"
        "wheel"
      ];
    };

    justagamer = {
      isNormalUser = true;
      initialPassword = "NixOS-justagamer.";
      createHome = true;
      extraGroups = [
        "audio"
        "disk"
        "networkmanager"
        "video"
        "wheel"
      ];
    };
  };

  tgap.system = {
    boot = {
      type = "encrypted-boot-btrfs";
      secDataPartlabel = "LinuxSecDataPartition";
    };

    network = {
      enable = true;
      inherit hostName;
      nameservers = ["9.9.9.9"];
      interfaces = ["enp4s0" "wlo1"];
    };
  };

  home-manager = lib.recursiveUpdate (mkHomeSettings {inherit config;}) {
    users = {
      twogoodap.imports = [../../users/twogoodap];
      workerap.imports = [../../users/workerap];
      justagamer.imports = [../../users/justagamer];
    };
  };
}
