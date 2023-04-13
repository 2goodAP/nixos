{
  hostName,
  nur,
  ...
}: {config, ...}: {
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
  };

  tgap.system = {
    boot.type = "encrypted-boot-btrfs";
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

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm.bak";

    sharedModules = [
      # Custom user modules.
      (import ../../modules/user)

      # NUR modules for `config.nur` options.
      nur.nixosModules.nur
    ];

    extraSpecialArgs = {
      sysPlasma5 = config.tgap.system.plasma5.enable;
      sysQmk = config.tgap.system.programs.qmk.enable;
      sysStateVersion = config.system.stateVersion;
    };

    users = {
      twogoodap.imports = [../../users/twogoodap];
      workerap.imports = [../../users/workerap];
    };
  };
}
