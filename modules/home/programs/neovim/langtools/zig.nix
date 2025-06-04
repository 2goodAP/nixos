{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim;
  inherit (lib) mkIf;
in
  mkIf (
    cfg.enable
    && builtins.elem "zig" cfg.langtools.languages
    && cfg.langtools.lsp.enable
  ) {
    programs.neovim = {
      extraPackages = with pkgs; [
        zig
        zlint
      ];

      extraLuaConfig = ''
        vim.lsp.enable("zls")
        vim.lsp.config("zls", {
          capabilities = require("tgap.lsp-utils").capabilities,
          on_attach = function(client, bufnr)
            require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
          end,
        })

        require("conform").setup({
          formatters_by_ft = {
            zir = {"zigfmt"},
            zig = {"zigfmt"},
            zon = {"zigfmt"},
          },
        })
      '';
    };
  }
