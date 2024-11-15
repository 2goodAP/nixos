# Configurations shared across the various nixos profiles.
{
  tgap.system = {
    desktop = {
      enable = true;
      manager = "plasma";
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
