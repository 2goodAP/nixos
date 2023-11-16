# Configurations shared across the various nixos profiles.
{
  tgap.system = {
    audio.enable = true;
    apparmor.enable = true;
    bluetooth.enable = true;
    desktop = {
      enable = true;
      manager = "wayland";
    };

    programs = {
      enable = true;
      androidTools.enable = true;
      glow.enable = true;
      qmk.enable = true;
      virtualisation.enable = true;

      neovim = {
        enable = true;

        autocompletion = {
          enable = true;
          dictionary.enable = true;
          snippets.enable = true;
        };

        filetype = {
          editorconfig.enable = true;
          glow.enable = true;
          neorg.enable = true;
        };

        git.enable = true;

        langtools = {
          dap.enable = true;

          languages = [
            "cpp"
            "haskell"
            "lua"
            "nix"
            "python"
            "rust"
            "typescript"
          ];

          lsp = {
            enable = true;
            lspsaga.enable = true;
            lspSignature.enable = true;
          };
        };

        motion = {
          enable = true;
          leap.enable = true;
        };

        statusline.enable = true;
        tabline.enable = true;
        telescope.enable = true;

        treesitter = {
          enable = true;
          extraPlugins.enable = true;
        };

        ui.enable = true;
      };
    };
  };
}
