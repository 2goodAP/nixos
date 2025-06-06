{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim;
  inherit (lib) getExe' mkIf mkMerge;
in
  mkIf (cfg.enable && builtins.elem "cpp" cfg.langtools.languages) (mkMerge [
    (mkIf cfg.langtools.lsp.enable {
      programs.neovim = {
        plugins = [pkgs.vimPlugins.clangd_extensions-nvim];

        extraPackages = with pkgs; [
          clang
          clang-tools
          flawfinder
        ];

        extraLuaConfig = ''
          vim.lsp.enable("clangd")
          vim.lsp.config("clangd", {
            capabilities = require("tgap.lsp-utils").capabilities,
            on_attach = function(client, bufnr)
              require("tgap.lsp-utils").set_lsp_keymaps(bufnr)
            end,
          })

          require("conform").setup({
            formatters_by_ft = {
              c = {"clang-format"},
              cpp = {"clang-format"},
            },
          })

          require("conform").formatters = {
            ["clang-format"] = {
              prepend_args = {
                  "--sort-includes",
                  "--style=google",
              }
            }
          }

          require("lint").linter_by_ft = {
            c = {"clangtidy"},
            cpp = {"clangtidy", "flawfinder"},
          }

          require("lint").linters.clangtidy.args = {
            "--checks=boost-*,bugprone-*,clang-analyzer-*,concurrency-*",
            "--checks=cppcoreguidelines-*,google-*,modernize-*,misc-*,mpi-*",
            "--checks=openmp-*,performance-*,portability-*,readibility-*",
            "--format-style=google",
            "--quiet",
          }
        '';
      };
    })

    (mkIf cfg.langtools.dap.enable {
      programs.neovim = {
        extraPackages = [pkgs.lldb];

        extraLuaConfig = ''
          require("dap").adapters.lldb = {
            type = "executable",
            command = "${getExe' pkgs.lldb "lldb-dap"}", -- Must be absolute path
            name = "lldb",
          }

          require("dap").configurations.cpp = {
            {
              name = "Launch",
              type = "lldb",
              request = "launch",
              program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
              end,
              cwd = "''${workspaceFolder}",
              stopOnEntry = false,
              args = {},
            },
          }

          require("dap").configurations.c = require("dap").configurations.cpp
        '';
      };
    })
  ])
