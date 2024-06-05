{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs;
  inherit (lib) mkIf optionalString;
in
  mkIf (
    builtins.elem "shell" cfg.neovim.langtools.languages
    && cfg.neovim.langtools.lsp.enable
  ) {
    environment.systemPackages = with pkgs; [
      bashls
      dotenv-linter
      shellcheck
      shellharden
      shfmt
      vale
    ];

    tgap.system.programs.neovim.luaExtraConfig = ''
      vim.filetype.add({
        -- Detect and apply filetypes based on the entire filename
        filename = {
          [".env"] = "dotenv",
          ["env"] = "dotenv",
        },
        -- Detect and apply filetypes based on certain patterns of the filenames
        pattern = {
          -- INFO: Match filenames like - ".env.example", ".env.local" and so on
          ["%.env%.[%w_.-]+"] = "dotenv",
        },
      })

      require("lspconfig").bashls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      ${optionalString (cfg.defaultShell == "nu") ''
        require("lspconfig").nushell.setup({
          capabilities = capabilities,
          on_attach = on_attach,
        })
      ''}

      require("conform").setup({
        formatters_by_ft = {
          sh = {{"shellharden", "shfmt"}},
        },
      })

      require("lint").linters_by_ft = {
        dotenv = {"dotenv_linter"},
        sh = {"shellcheck"},
      }
    '';
  }
