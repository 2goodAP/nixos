# Configurations shared across the various nixos profiles.
{...}: {
  tgap.system = {
    audio.enable = true;
    apparmor.enable = true;
    bluetooth.enable = true;
    plasma5.enable = true;

    programs = {
      enable = true;
      android-tools.enable = true;
      fd.enable = true;
      glow.enable = true;
      qmk.enable = true;
      ripgrep.enable = true;
      virtualisation.enable = true;

      neovim = {
        enable = true;

        autocompletion = {
          enable = true;
          dictionary.enable = true;
          snippets.enable = true;
        };

        filetype = {
          enable = true;
          editorconfig.enable = true;
          glow.enable = true;
          neorg.enable = true;
        };

        lsp = {
          enable = true;
          languages = [
            "cpp"
            "lua"
            "nix"
            "python"
            "typescript"
          ];
          lspsaga.enable = true;
          lspSignature.enable = true;
        };

        treesitter = {
          enable = true;
          extraPlugins.enable = true;
        };
      };
    };
  };
}
