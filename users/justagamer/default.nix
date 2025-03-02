let
  uname = builtins.baseNameOf ./.;
in {
  users.users."${uname}" = {
    isNormalUser = true;
    initialPassword = "NixOS-${uname}.";
    createHome = true;
    extraGroups = [
      "audio"
      "disk"
      "networkmanager"
      "video"
      "wheel"
    ];
  };

  home-manager.users."${uname}" = {pkgs, ...}: {
    imports = [
      ../common/programs.nix
      ../common/applications.nix
    ];

    home.packages = [pkgs.ryujinx];
    tgap.home.desktop.gaming.enable = true;

    xdg.desktopEntries = let
      wineDir = "/home/${uname}/Wine";
    in {
      dead-cells = {
        categories = ["Game"];
        comment = "Motion Twin: Adventure, Action Roguelike";
        exec =
          "GAMEID=588650 umu-launch -emx"
          + " ${wineDir}/Games/Dead_Cells deadcells.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/Dead_Cells/DC_Icon.png";
        name = "Dead Cells";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      divinity-original-sin-2 = {
        categories = ["Game"];
        comment = "Larian: Tactical RPG, Turn-Based Strategy";
        exec =
          ''GAMEID=435150 umu-launch -emt "GE-Proton8-32"''
          + " ${wineDir}/Games/Divinity_Original_Sin_2"
          + " DefEd/bin/EoCApp.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/DOS2/DOS2_Icon.png";
        name = "Divinity Original Sin 2";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      hades = {
        categories = ["Game"];
        comment = "Supergiant: Action Roguelike, Hack and Slash";
        exec =
          "GAMEID=1145360 umu-launch -em"
          + " ${wineDir}/Games/Hades x64/Hades.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/Hades/Hades_Icon.png";
        name = "Hades";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      into-the-breach = {
        categories = ["Game"];
        comment = "Subset Games: Turn-Based Strategy, Mechs";
        exec =
          "GAMEID=590380 umu-launch -emx"
          + " ${wineDir}/Games/Into_the_Breach Breach.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/Breach/Breach_Icon.png";
        name = "Into the Breach";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      slay-the-spire = {
        categories = ["Game"];
        comment = "Mega Crit: Roguelike, Deckbuilder";
        exec =
          "GAMEID=646570 umu-launch -mx"
          + " ${wineDir}/Games/Slay_the_Spire SlayTheSpire.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/StS/StS_Icon.png";
        name = "Slay the Spire";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      star-of-providence = {
        categories = ["Game"];
        comment = "Team D-13: Bullet Hell, Action Roguelike";
        exec =
          "GAMEID=603960 umu-launch -mx"
          + " ${wineDir}/Games/Monolith Star_of_Providence.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/SoP/SoP_Icon.png";
        name = "Star of Providence";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      # animal-well = {
      #   categories = ["Game"];
      #   comment = "Billy Basso: Exploration, Metroidvania";
      #   exec =
      #     "GAMEID=813230 umu-launch -em"
      #     + " ${wineDir}/Games/Animal_Well SmartSteamLoader_x64.exe";
      #   genericName = "Game";
      #   icon = "${wineDir}/Misc/Animal_Well/AW_Icon.png";
      #   name = "Animal Well";
      #   prefersNonDefaultGPU = true;
      #   settings = {DBusActivatable = "false";};
      # };

      # dishonored-2 = {
      #   categories = ["Game"];
      #   comment = "Arcane: Stealth, First-Person";
      #   exec =
      #     "GAMEID=403640 umu-launch -em"
      #     + " ${wineDir}/Games/Dishonored_2 Dishonored2.exe";
      #   genericName = "Game";
      #   icon = "${wineDir}/Misc/Dishonored_2/Dishonored2_Icon.png";
      #   name = "Dishonored 2";
      #   prefersNonDefaultGPU = true;
      #   settings = {DBusActivatable = "false";};
      # };

      # hollow-knight = {
      #   categories = ["Game"];
      #   comment = "Team Cherry: Metroidvania, Souls-like";
      #   exec =
      #     "GAMEID=367520 umu-launch -em"
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
      #     "GAMEID=1057090 umu-launch -emx"
      #     + " ${wineDir}/Games/Ori_and_the_Will_of_the_Wisps"
      #     + " oriwotw.exe";
      #   genericName = "Game";
      #   icon = "${wineDir}/Misc/Ori/WotW_Icon.png";
      #   name = "Ori and the Will of the Wisps";
      #   prefersNonDefaultGPU = true;
      #   settings = {DBusActivatable = "false";};
      # };

      # red-dead-redemption-2 = {
      #   categories = ["Game"];
      #   comment = "Rockstar: Open World, Story Rich, Western";
      #   exec =
      #     ''PROTON_ENABLE_NVAPI=1 WINEDLLOVERRIDES="dinput8,version=n,b"''
      #     + " GAMEID=1174180 umu-launch -em"
      #     + " ${wineDir}/Games/Red_Dead_Redemption_2 Launcher.exe";
      #   genericName = "Game";
      #   icon = "${wineDir}/Misc/RDR2/RDR2_Icon.png";
      #   name = "Red Dead Redemption 2";
      #   prefersNonDefaultGPU = true;
      #   settings = {DBusActivatable = "false";};
      # };

      # shadow-gambit = {
      #   categories = ["Game"];
      #   comment = "Mimimi: Strategy, Tactical RPG, Stealth";
      #   exec =
      #     "GAMEID=1545560 umu-launch -em"
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
