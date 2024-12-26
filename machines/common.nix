# Configurations shared across the various nixos profiles.
{
  tgap.system = {
    desktop = {
      enable = true;
      manager = "plasma";
    };

    network.allowedPorts = {
      localsend = 53317;
      aria2 = 55000;
    };

    programs = {
      enable = true;
      androidTools.enable = true;
      iosTools.enable = true;
      qmk.enable = true;
      virtualisation.enable = true;
    };
  };
}
