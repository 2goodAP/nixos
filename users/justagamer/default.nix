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
    imports = [../common];
    tgap.home.desktop.gaming.enable = true;
    home.packages = [pkgs.ryujinx];

    xdg.desktopEntries = {
      dmc5 = {
        categories = ["Game"];
        comment = "CAPCOM: Devil May Cry 5";
        exec = (
          "env launch-game -fm /home/${uname}/Wine/Games/Devil_May_Cry_5"
          + " DevilMayCry5.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/DMC5/DMC5_Icon.png";
        name = "DMC5";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };

      dishonored2 = {
        categories = ["Game"];
        comment = "Arcane: Dishonored 2";
        exec = (
          "env launch-game -fm /home/${uname}/Wine/Games/Dishonored_2"
          + " Dishonored2.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Dishonored_2/Dishonored2_Icon.png";
        name = "Dishonored 2";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };

      dos2 = {
        categories = ["Game"];
        comment = "Larian: Divinity Original Sin 2 - Definitive Edition";
        exec = (
          "env launch-game -fm /home/${uname}/Wine/Games/Divinity_Original_Sin_2"
          + " DefEd/bin/EoCApp.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/DOS2/DOS2_Icon.png";
        name = "Divinity Original Sin 2";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };

      ghostTrick = {
        categories = ["Game"];
        comment = "CAPCOM: Ghost Trick - Phantom Detective";
        exec = (
          "env launch-game -fm /home/${uname}/Wine/Games/Ghost_Trick_Phantom_Detective"
          + " Ghost_Trick.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Ghost_Trick/Ghost_Trick_Icon.png";
        name = "Ghost Trick";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };

      hades = {
        categories = ["Game"];
        comment = "Supergiant: Hades - The Godlike Roguelike";
        exec = "env launch-game -fm /home/${uname}/Wine/Games/Hades x64/Hades.exe";
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Hades/Hades_Icon.png";
        name = "Hades";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };

      manifoldGarden = {
        categories = ["Game"];
        comment = "Willian Chyr: Manifold Garden";
        exec = (
          "env launch-game -fm /home/${uname}/Wine/Games/Manifold_Garden"
          + " ManifoldGarden.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Manifold_Garden/Manifold_Garden_Icon.png";
        name = "Manifold Garden";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };

      rdr2 = {
        categories = ["Game"];
        comment = "Rockstar: Red Dead Redemption 2";
        exec = (
          ''env PROTON_ENABLE_NVAPI=1 WINEDLLOVERRIDES="dinput8,version=n,b" ''
          + "launch-game -fm /home/${uname}/Wine/Games/Red_Dead_Redemption_2 Launcher.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/RDR2/RDR2_Icon.png";
        name = "RDR2";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };

      shadowGambit = {
        categories = ["Game"];
        comment = "Mimimi: Shadow Gambit - The Cursed Crew";
        exec = (
          "env launch-game -fm /home/${uname}/Wine/Games/Shadow_Gambit_The_Cursed_Crew"
          + " ShadowGambit_TCC.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Shadow_Gambit/SG_Icon.png";
        name = "Shadow Gambit";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };

      talos = {
        categories = ["Game"];
        comment = "Croteam: The Talos Principle";
        exec = (
          "env launch-game -fm /home/${uname}/Wine/Games/The_Talos_Principle"
          + " Bin/x64/Talos.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Talos/Talos_Icon.png";
        name = "Talos";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };

      transistor = {
        categories = ["Game"];
        comment = "Supergiant: Transistor";
        exec = (
          "env launch-game -w 1920 -h 1080 -fm /home/${uname}/Wine/Games/Transistor"
          + " Transistor.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Transistor/Transistor_Icon.png";
        name = "Transistor";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };
    };
  };
}
