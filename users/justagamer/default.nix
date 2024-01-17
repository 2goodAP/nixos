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

    home.packages = with pkgs; [
      rpcs3
      ryujinx
    ];

    xdg.desktopEntries = {
      dos2 = {
        categories = ["Game"];
        comment = "Divinity Original Sin 2 - Definitive Edition";
        exec = "env launch-game -fm /home/${uname}/Wine/Games/Divinity_Original_Sin_2 DefEd/bin/EoCApp.exe";
        genericName = "Game";
        icon = "/home/${uname}/Wine/Games/Divinity_Original_Sin_2/goggame-1326441817.ico";
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
        exec = ''env WINEDLLOVERRIDES="dinput8,version=n,b" launch-game -fm /home/${uname}/Wine/Games/Red_Dead_Redemption_2 Launcher.exe'';
        genericName = "Game";
        icon = "/home/${uname}/Wine/Misc/RDR2/RDR2_icon.png";
        name = "RDR2";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };

      shadowGambit = {
        categories = ["Game"];
        comment = "Shadow Gambit - The Cursed Crew";
        exec = "env launch-game -fm /home/${uname}/Wine/Games/Shadow_Gambit_The_Cursed_Crew ShadowGambit_TCC.exe";
        genericName = "Game";
        icon = "/home/${uname}/Wine/Games/Shadow_Gambit_The_Cursed_Crew/goggame-1889957442.ico";
        name = "Shadow Gambit";
        prefersNonDefaultGPU = true;
        settings = {DBusActivatable = "false";};
        terminal = true;
      };
    };
  };
}
