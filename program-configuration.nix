# Program configurations for the various nixos profiles.

{ lib, pkgs, ... }:

{
  environment = {
    shells = [ pkgs.bashInteractive pkgs.zsh ];

    variables = {
      TERMINFO_DIRS = [
        "${pkgs.alacritty.terminfo}/share/terminfo"
	      "${pkgs.foot.terminfo}/share/terminfo"
      ];
    };
  };


  programs = {
    bash.vteIntegration = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    light.enable = true;

    zsh = {
      enable = true;
      vteIntegration = true;
      autosuggestions.enable = true;
      syntaxHighlighting = {
        enable = true;
	      highlighters = [ "main" "brackets" "pattern" ];
      };
      promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      shellInit = "source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh";
    };
  };


  # Settings for VirtualBox.
  virtualisation = {
    docker = {
      enable = true;
      enableNvidia = true;
    };

    virtualbox = {
      guest.enable = false;
      host.enable = true;
    };
  };
}
