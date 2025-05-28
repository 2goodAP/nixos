# Configurations shared across the various user profiles.
{
  tgap.home = {
    programs = {
      enable = true;

      neovim = {
        enable = true;
        git.enable = true;
        statusline.enable = true;
        tabline.enable = true;
        telescope.enable = true;
        ui.enable = true;

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

        langtools = {
          dap.enable = true;

          languages = [
            "cpp"
            "go"
            "haskell"
            "hypr"
            "lisp"
            "lua"
            "markdown"
            "nix"
            "python"
            "r"
            "rust"
            "shell"
            "sql"
            "typescript"
            "xml"
          ];

          lsp = {
            enable = true;
            lspsaga.enable = true;
            lspSignature.enable = true;
          };
        };

        motion = {
          enable = true;
          harpoon.enable = true;
          leap.enable = true;
        };

        treesitter = {
          enable = true;
          extraPlugins.enable = true;
        };
      };
    };
  };
}
