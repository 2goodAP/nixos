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

    home.packages = with pkgs; [
      rpcs3
      ryujinx
    ];

    xdg.desktopEntries = {
      dishonored2 = {
        categories = ["Game"];
        comment = "Dishonored 2";
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
        comment = "Divinity Original Sin 2 - Definitive Edition";
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

      hades = {
        categories = ["Game"];
        comment = "Hades - The Godlike Roguelike";
        exec = "env launch-game -fm /home/${uname}/Wine/Games/Hades x64/Hades.exe";
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Hades/Hades_Icon.png";
        name = "Hades";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };

      rdr2 = {
        categories = ["Game"];
        comment = "Red Dead Redemption 2";
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
        comment = "Shadow Gambit - The Cursed Crew";
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
    };
  };
}
