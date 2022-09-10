{ hostName, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../share/laptop
  ];


  # Bootloader
  machine = {
    loader = {
        enable = true;
        enableFullEncrypt = true;
        espMountPoint = "/efi";
    };

    network = {
      enable = true;
      inherit hostName;
      nameservers = [ "1.1.1.1" "9.9.9.9" ];
      interfaces = [ "wlp0s20f3" "enp7s0f1" ];
    };
  };


  # Set time zone.
  time.timeZone = "Asia/Kathmandu";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # Enable ssh.
  services.openssh.enable = true;


  console = {
    font = "Lat2-Terminus18";
    keyMap = "us";
    packages = [ pkgs.terminus_font ];
  };


  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # Hardware
    acpi
    gparted
    gptfdisk
    ntfs3g
    pamixer
    pulseaudio

    # Programs
    busybox
    cmus
    conda
    docker-compose
    git
    jq
		(neovim.override { withNodeJs = true; })
    (python39.withPackages (pks: with pks; [ black mypy pylint pynvim ]))
    (python310.withPackages (pks: with pks; [ black mypy pylint pynvim ]))
    p7zip
    ranger
    unrar
    unzip
    tmux
    wget
    zip
  ];


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "22.05";
}
