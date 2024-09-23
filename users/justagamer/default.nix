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

    xdg.desktopEntries = {
      animalWell = {
        categories = ["Game"];
        comment = "Billy Basso: Animal Well";
        exec = (
          "launch-game -fm /home/${uname}/Wine/Games/Animal_Well"
          + " SmartSteamLoader_x64.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Animal_Well/AW_Icon.png";
        name = "Animal Well";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      darkestDungeon2 = {
        categories = ["Game"];
        comment = "Red Hook Studios: Darkest Dungeon II";
        exec = (
          "launch-game -fm /home/${uname}/Wine/Games/Darkest_Dungeon_II"
          + " DarkestDungeonII.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Darkest_Dungeon/DD2_Icon.png";
        name = "Darkest Dungeon II";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      dmc5 = {
        categories = ["Game"];
        comment = "CAPCOM: Devil May Cry 5";
        exec = (
          "launch-game -fm /home/${uname}/Wine/Games/Devil_May_Cry_5"
          + " DevilMayCry5.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/DMC5/DMC5_Icon.png";
        name = "Devil May Cry 5";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      dishonored2 = {
        categories = ["Game"];
        comment = "Arcane: Dishonored 2";
        exec = "launch-game -fm /home/${uname}/Wine/Games/Dishonored_2 Dishonored2.exe";
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Dishonored_2/Dishonored2_Icon.png";
        name = "Dishonored 2";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      divinityOriginalSin2 = {
        categories = ["Game"];
        comment = "Larian: Divinity Original Sin 2 - Definitive Edition";
        exec = (
          "launch-game -fm /home/${uname}/Wine/Games/Divinity_Original_Sin_2"
          + " DefEd/bin/EoCApp.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/DOS2/DOS2_Icon.png";
        name = "Divinity Original Sin 2";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      ghostTrick = {
        categories = ["Game"];
        comment = "CAPCOM: Ghost Trick - Phantom Detective";
        exec = (
          "launch-game -fm /home/${uname}/Wine/Games/Ghost_Trick_Phantom_Detective"
          + " Ghost_Trick.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Ghost_Trick/GT_Icon.png";
        name = "Ghost Trick";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      hades = {
        categories = ["Game"];
        comment = "Supergiant: Hades - The Godlike Roguelike";
        exec = "launch-game -fm /home/${uname}/Wine/Games/Hades x64/Hades.exe";
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Hades/Hades_Icon.png";
        name = "Hades";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      hollowKnight = {
        categories = ["Game"];
        comment = "Team Cherry: Hollow Knight";
        exec = (
          "launch-game -fm /home/${uname}/Wine/Games/Hollow_Knight"
          + " HollowKnight.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Hollow_Knight/HK_Icon.png";
        name = "Hollow Knight";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      intoTheBreach = {
        categories = ["Game"];
        comment = "Subset Games: Into the Breach";
        exec = (
          "launch-game -fm /home/${uname}/Wine/Games/Into_the_Breach"
          + " Breach.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Breach/Breach_Icon.png";
        name = "Into the Breach";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      kingdomComeDeliverance = {
        categories = ["Game"];
        comment = "Warhorse Studios: Kingdom Come Deliverance";
        exec = (
          "launch-game -fm /home/${uname}/Wine/Games/Kingdom_Come_Deliverance"
          + " Bin/Win64/KingdomCome.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/KCD/KCD_Icon.png";
        name = "Kingdom Come: Deliverance";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      newNTasty = {
        categories = ["Game"];
        comment = "Oddworld Inhabitants: Oddworld New n Tasty";
        exec = "launch-game -fm /home/${uname}/Wine/Games/Oddworld_New_n_Tasty NNT.exe";
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Oddworld/NNT_Icon.png";
        name = "New n Tasty";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      prey = {
        categories = ["Game"];
        comment = "Arcane: Prey";
        exec = (
          "launch-game -fm /home/${uname}/Wine/Games/Prey"
          + " Binaries/Danielle/x64-GOG/Release/Prey.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Prey/Prey_Icon.png";
        name = "Prey";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      rdr2 = {
        categories = ["Game"];
        comment = "Rockstar: Red Dead Redemption 2";
        exec = (
          ''PROTON_ENABLE_NVAPI=1 WINEDLLOVERRIDES="dinput8,version=n,b"''
          + " launch-game -fm /home/${uname}/Wine/Games/Red_Dead_Redemption_2"
          + " Launcher.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/RDR2/RDR2_Icon.png";
        name = "RDR2";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };

      shadowGambit = {
        categories = ["Game"];
        comment = "Mimimi: Shadow Gambit - The Cursed Crew";
        exec = (
          "launch-game -fm /home/${uname}/Wine/Games/Shadow_Gambit_The_Cursed_Crew"
          + " ShadowGambit_TCC.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Shadow_Gambit/SG_Icon.png";
        name = "Shadow Gambit";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
      };
    };
  };
}
