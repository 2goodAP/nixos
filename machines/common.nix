# Configurations shared across the various nixos profiles.
{
  tgap.system = {
    audio.enable = true;
    apparmor.enable = true;
    bluetooth.enable = true;

    desktop = {
      enable = true;
      manager = "plasma";
    };

    programs = {
      enable = true;
      androidTools.enable = true;
      defaultShell = "nu";
      iosTools.enable = true;
      qmk.enable = true;
      virtualisation.enable = true;
    };
  };
}
