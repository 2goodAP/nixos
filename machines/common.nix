# Configurations shared across the various nixos profiles.
{
  tgap.system = {
    desktop = {
      enable = true;
      manager = "niri";
    };

    network = {
      allowedPorts.aria2 = 6800;

      allowedPortRanges = {
        aria2 = {
          from = 6881;
          to = 6999;
        };
        localsend = {
          from = 53316;
          to = 53318;
        };
      };
    };

    programs = {
      enable = true;
      androidTools.enable = true;
      iosTools.enable = true;
    };
  };
}
