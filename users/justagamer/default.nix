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

      wolfensteinNewOrder = {
        categories = ["Game"];
        comment = "Wolfenstein - The New Order";
        exec = (
          ''env WINEDLLOVERRIDES="dinput8=n,b" launch-game -r 100 -F 100 -fm ''
          + "/home/${uname}/Wine/Games/Wolfenstein_The_New_Order WolfNewOrder_x64.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Wolfenstein_New_Order/New_Order_Icon.png";
        name = "The New Order";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };

      wolfensteinOldBlood = {
        categories = ["Game"];
        comment = "Wolfenstein - The Old Blood";
        exec = (
          ''env WINEDLLOVERRIDES="dinput8=n,b" launch-game -r 100 -F 100 -fm ''
          + "/home/${uname}/Wine/Games/Wolfenstein_The_Old_Blood WolfOldBlood_x64.exe"
        );
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/Wolfenstein_Old_Blood/Old_Blood_Icon.png";
        name = "The Old Blood";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };
    };
  };
}
