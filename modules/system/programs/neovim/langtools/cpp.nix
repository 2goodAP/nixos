{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim;
  inherit (lib) mkIf mkMerge;
in
  mkIf (builtins.elem "cpp" cfg.langtools.languages) (mkMerge [
    (mkIf cfg.langtools.lsp.enable {
      environment.systemPackages = [pkgs.clang pkgs.flawfinder];
      tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.clangd_extensions-nvim];

      tgap.system.programs.neovim.luaExtraConfig = ''
        require("lspconfig").clangd.setup({
          capabilities = capabilities,
          on_attach = on_attach,
        })

        require("conform").setup({
          formatters_by_ft = {
            c = {"clang-format"},
            cpp = {"clang-format"},
          },
        })

        require("lint").linter_by_ft = {
          c = {"clangtidy"},
          cpp = {"clangtidy", "flawfinder"},
        }
      '';
    })

    (mkIf cfg.langtools.dap.enable {
      environment.systemPackages = [pkgs.lldb];

      tgap.system.programs.neovim.luaExtraConfig = ''
        local dap = require("dap")

        dap.adapters.lldb = {
          type = "executable",
          command = "${pkgs.lldb}/bin/lldb-vscode", -- Must be absolute path
          name = "lldb",
        }

        dap.configurations.cpp = {
          {
            name = "Launch",
            type = "lldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "$workspaceFolder",
            stopOnEntry = false,
            args = {},
          },
        }

        dap.configurations.c = dap.configurations.cpp
      '';
    })
  ])
