{
  lib,
  pkgs,
  sysStateVersion,
  ...
}: {
  imports = [
    ./programs
    ./desktop
  ];

  home = let
    inherit (lib) getExe getExe';
  in {
    stateVersion = sysStateVersion;

    activation.homeDirPermissions = ''
      ${getExe' pkgs.coreutils "test"} -d $HOME \
        && ${getExe pkgs.fd} --full-path $HOME -IHt d -X \
          ${getExe' pkgs.acl "setfacl"} -Pdm u::rwx,g::-,o::- \
        || :
    '';
  };
}
