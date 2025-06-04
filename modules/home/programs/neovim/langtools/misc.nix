{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim;
  inherit (lib) mkIf mkMerge;
in
  mkIf (cfg.enable && cfg.langtools.lsp.enable) (mkMerge [
    {
      programs.neovim = {
        extraPackages = [pkgs.harper];

        extraLuaConfig = ''
          vim.lsp.enable("harper_ls")
          vim.lsp.config("harper_ls", {
            settings = {
              ["harper-ls"] = {
                userDictPath = "${config.xdg.dataHome}/harper/user_dict.txt",
              },
            },

            capabilities = require("tgap.lsp-utils").capabilities,
            on_attach = function(client, bufnr)
              require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
            end,
          })
        '';
      };
    }

    (mkIf (builtins.elem "hypr" cfg.langtools.languages) {
      programs.neovim = {
        extraPackages = [pkgs.hyprls];

        extraLuaConfig = ''
          vim.lsp.enable("hyprls")
          vim.lsp.config("hyprls", {
            capabilities = require("tgap.lsp-utils").capabilities,
            on_attach = function(client, bufnr)
              require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
            end,
          })
        '';
      };
    })

    (mkIf (builtins.elem "lisp" cfg.langtools.languages) {
      programs.neovim.plugins = [pkgs.vimPlugins.parinfer-rust];
    })
  ])
