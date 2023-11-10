{sysStateVersion, ...}: {
  imports = [
    ./programs
    ./desktop
  ];

  config = {
    home.stateVersion = sysStateVersion;
  };
}
