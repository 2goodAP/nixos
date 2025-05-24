# Configurations shared across the various nixos profiles.
{
  tgap.system = {
    desktop = {
      enable = true;
      manager = "niri";
    };

    network = {
      allowedPorts.aria2 = 55000;
      allowedPortRanges.localsend = {
        from = 53316;
        to = 53318;
      };
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
