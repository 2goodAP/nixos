let
  uname = baseNameOf ./.;
in {
  users.users."${uname}" = {
    isNormalUser = true;
    initialPassword = "NixOS-${uname}.";
    createHome = true;
    extraGroups = [
      "disk"
      "networkmanager"
      "video"
      "wheel"
    ];
  };

  home-manager.users."${uname}" = {
    lib,
    pkgs,
    ...
  }: {
    imports = [
      ../common/programs.nix
      ../common/applications.nix
    ];

    home.packages = [pkgs.ryujinx];
    tgap.home.desktop.gaming.enable = true;

    xdg.desktopEntries = let
      wineDir = "/home/${uname}/Wine";
      inherit (lib) getExe';
    in {
      divinity-original-sin-2 = let
        gameDir = "Divinity_Original_Sin_2";
      in {
        categories = ["Game"];
        comment = "Larian: Tactical RPG, Turn-Based Strategy";
        exec =
          ''${getExe' pkgs.coreutils "env"} GAMEID=435150 umu-launch -emp "${gameDir}" -t "GE-Proton8-32"''
          + " ${wineDir}/Games/${gameDir}/DefEd/bin EoCApp.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/DOS2/DOS2_Icon.png";
        name = "Divinity Original Sin 2";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      into-the-breach = {
        categories = ["Game"];
        comment = "Subset Games: Turn-Based Strategy, Mechs";
        exec =
          "${getExe' pkgs.coreutils "env"} GAMEID=590380 umu-launch -emx"
          + " ${wineDir}/Games/Into_the_Breach Breach.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/Breach/Breach_Icon.png";
        name = "Into the Breach";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      red-dead-redemption-2 = {
        categories = ["Game"];
        comment = "Rockstar: Open World, Story Rich, Western";
        exec =
          "${getExe' pkgs.coreutils "env"} PROTON_ENABLE_NVAPI=1 "
          + ''WINEDLLOVERRIDES="dinput8=n,b" GAMEID=1174180''
          + " umu-launch -m ${wineDir}/Games/Red_Dead_Redemption_2 Launcher.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/RDR2/RDR2_Icon.png";
        name = "Red Dead Redemption 2";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      roboquest = {
        categories = ["Game"];
        comment = "RyseUp Studios: FPS, Action Roguelike";
        exec =
          "${getExe' pkgs.coreutils "env"} GAMEID=692890 umu-launch -em"
          + ''t "Proton 6.3" ${wineDir}/Games/Roboquest RoboQuest.exe'';
        genericName = "Game";
        icon = "${wineDir}/Misc/Roboquest/Roboquest_Icon.png";
        name = "Roboquest";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      # dead-cells = {
      #   categories = ["Game"];
      #   comment = "Motion Twin: Adventure, Action Roguelike";
      #   exec =
      #     "${getExe' pkgs.coreutils "env"} GAMEID=588650 umu-launch -emx"
      #     + " ${wineDir}/Games/Dead_Cells deadcells.exe";
      #   genericName = "Game";
      #   icon = "${wineDir}/Misc/Dead_Cells/DC_Icon.png";
      #   name = "Dead Cells";
      #   prefersNonDefaultGPU = true;
      #   settings = {DBusActivatable = "false";};
      # };

      # hades = {
      #   categories = ["Game"];
      #   comment = "Supergiant: Action Roguelike, Hack and Slash";
      #   exec =
      #     "${getExe' pkgs.coreutils "env"} GAMEID=1145360 umu-launch -em"
      #     + " ${wineDir}/Games/Hades x64/Hades.exe";
      #   genericName = "Game";
      #   icon = "${wineDir}/Misc/Hades/Hades_Icon.png";
      #   name = "Hades";
      #   prefersNonDefaultGPU = true;
      #   settings = {DBusActivatable = "false";};
      # };

      # hollow-knight = {
      #   categories = ["Game"];
      #   comment = "Team Cherry: Metroidvania, Souls-like";
      #   exec =
      #     "${getExe' pkgs.coreutils "env"} GAMEID=367520 umu-launch -em"
      #     + " ${wineDir}/Games/Hollow_Knight HollowKnight.exe";
      #   genericName = "Game";
      #   icon = "${wineDir}/Misc/Hollow_Knight/HK_Icon.png";
      #   name = "Hollow Knight";
      #   prefersNonDefaultGPU = true;
      #   settings = {DBusActivatable = "false";};
      # };

      # ori-will-of-the-wisps = {
      #   categories = ["Game"];
      #   comment = "Moon Studios GmbH: Metroidvania, Platformer, Action";
      #   exec =
      #     "${getExe' pkgs.coreutils "env"} GAMEID=1057090 umu-launch -emx"
      #     + " ${wineDir}/Games/Ori_and_the_Will_of_the_Wisps"
      #     + " oriwotw.exe";
      #   genericName = "Game";
      #   icon = "${wineDir}/Misc/Ori/WotW_Icon.png";
      #   name = "Ori and the Will of the Wisps";
      #   prefersNonDefaultGPU = true;
      #   settings = {DBusActivatable = "false";};
      # };

      # shadow-gambit = {
      #   categories = ["Game"];
      #   comment = "Mimimi: Strategy, Tactical RPG, Stealth";
      #   exec =
      #     "${getExe' pkgs.coreutils "env"} GAMEID=1545560 umu-launch -em"
      #     + " ${wineDir}/Games/Shadow_Gambit_The_Cursed_Crew"
      #     + " ShadowGambit_TCC.exe";
      #   genericName = "Game";
      #   icon = "${wineDir}/Misc/Shadow_Gambit/SG_Icon.png";
      #   name = "Shadow Gambit";
      #   prefersNonDefaultGPU = true;
      #   settings = {DBusActivatable = "false";};
      # };
    };
  };
}
