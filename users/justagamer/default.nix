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
      animal-well = {
        categories = ["Game"];
        comment = "Billy Basso: Exploration, Metroidvania";
        exec =
          "GAMEID=813230 umu-launch -fm"
          + " ${wineDir}/Games/Animal_Well SmartSteamLoader_x64.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/Animal_Well/AW_Icon.png";
        name = "Animal Well";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      balatro = {
        categories = ["Game"];
        comment = "Playstack: Roguelike, Deckbuilder";
        exec = "GAMEID=2379780 umu-launch -fm ${wineDir}/Games/Balatro Balatro.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/Balatro/Balatro_Icon.png";
        name = "Balatro";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      # devil-may-cry-5 = {
      #   categories = ["Game"];
      #   comment = "CAPCOM: Action, Hack and Slash";
      #   exec =
      #     "GAMEID=601150 umu-launch -fm"
      #     + " ${wineDir}/Games/Devil_May_Cry_5 DevilMayCry5.exe";
      #   genericName = "Game";
      #   icon = "${wineDir}/Misc/DMC5/DMC5_Icon.png";
      #   name = "Devil May Cry 5";
      #   prefersNonDefaultGPU = true;
      #   settings = {DBusActivatable = "false";};
      # };

      # dishonored-2 = {
      #   categories = ["Game"];
      #   comment = "Arcane: Stealth, First-Person";
      #   exec =
      #     "GAMEID=403640 umu-launch -fm"
      #     + " ${wineDir}/Games/Dishonored_2 Dishonored2.exe";
      #   genericName = "Game";
      #   icon = "${wineDir}/Misc/Dishonored_2/Dishonored2_Icon.png";
      #   name = "Dishonored 2";
      #   prefersNonDefaultGPU = true;
      #   settings = {DBusActivatable = "false";};
      # };

      # divinity-original-sin-2 = {
      #   categories = ["Game"];
      #   comment = "Larian: Tactical RPG, Turn-Based Strategy";
      #   exec =
      #     ''GAMEID=435150 umu-launch -fmP "Proton - Experimental"''
      #     + " ${wineDir}/Games/Divinity_Original_Sin_2"
      #     + " DefEd/bin/EoCApp.exe";
      #   genericName = "Game";
      #   icon = "${wineDir}/Misc/DOS2/DOS2_Icon.png";
      #   name = "Divinity Original Sin 2";
      #   prefersNonDefaultGPU = true;
      #   settings = {DBusActivatable = "false";};
      # };

      god-of-war-ragnarok = {
        categories = ["Game"];
        comment = "Sony Santa Monica: Action, Story Rich, Adventure";
        exec =
          ''WINEDLLOVERRIDES="version,xinput1_4=n,b" GAMEID=2322010''
          + " PROTON_ENABLE_NVAPI=1 umu-launch -fmxp God_of_War"
          + " ${wineDir}/Games/God_of_War_Ragnarok GoWR.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/GoWR/GoWR_Icon.png";
        name = "God of War Ragnarok";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      hades = {
        categories = ["Game"];
        comment = "Supergiant: Action Roguelike, Hack and Slash";
        exec =
          "GAMEID=1145360 umu-launch -fm"
          + " ${wineDir}/Games/Hades x64/Hades.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/Hades/Hades_Icon.png";
        name = "Hades";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      hollow-knight = {
        categories = ["Game"];
        comment = "Team Cherry: Metroidvania, Souls-like";
        exec =
          "GAMEID=367520 umu-launch -fm"
          + " ${wineDir}/Games/Hollow_Knight HollowKnight.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/Hollow_Knight/HK_Icon.png";
        name = "Hollow Knight";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      into-the-breach = {
        categories = ["Game"];
        comment = "Subset Games: Turn-Based Strategy, Mechs";
        exec =
          "GAMEID=590380 umu-launch -fm"
          + " ${wineDir}/Games/Into_the_Breach Breach.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/Breach/Breach_Icon.png";
        name = "Into the Breach";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      new-n-tasty = {
        categories = ["Game"];
        comment = "Oddworld Inhabitants: Puzzle Platformer, Adventure";
        exec =
          "GAMEID=314660 umu-launch -fm"
          + " ${wineDir}/Games/Oddworld_New_n_Tasty NNT.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/Oddworld/NNT_Icon.png";
        name = "New n Tasty";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      ori-will-of-the-wisps = {
        categories = ["Game"];
        comment = "Moon Studios GmbH: Metroidvania, Platformer, Action";
        exec =
          "GAMEID=1057090 umu-launch -fmx"
          + " ${wineDir}/Games/Ori_and_the_Will_of_the_Wisps"
          + " oriwotw.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/Ori/WotW_Icon.png";
        name = "Ori and the Will of the Wisps";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      # red-dead-redemption-2 = {
      #   categories = ["Game"];
      #   comment = "Rockstar: Open World, Story Rich, Western";
      #   exec =
      #     ''PROTON_ENABLE_NVAPI=1 WINEDLLOVERRIDES="dinput8,version=n,b"''
      #     + " GAMEID=1174180 umu-launch -fm"
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
      #     "GAMEID=1545560 umu-launch -fm"
      #     + " ${wineDir}/Games/Shadow_Gambit_The_Cursed_Crew"
      #     + " ShadowGambit_TCC.exe";
      #   genericName = "Game";
      #   icon = "${wineDir}/Misc/Shadow_Gambit/SG_Icon.png";
      #   name = "Shadow Gambit";
      #   prefersNonDefaultGPU = true;
      #   settings = {DBusActivatable = "false";};
      # };

      ufo-50 = {
        categories = ["Game"];
        comment = "Mossmouth: Retro, 50-in-1";
        exec =
          "GAMEID=1147860 umu-launch -w 1920 -h 1080 -fmx"
          + " ${wineDir}/Games/UFO_50 ufo50.exe";
        genericName = "Game";
        icon = "${wineDir}/Misc/UFO_50/UFO_Icon.ico";
        name = "UFO 50";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };
    };
  };
}
