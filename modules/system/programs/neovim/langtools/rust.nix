{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim;
  inherit (lib) mkIf mkMerge;
in
  mkIf (builtins.elem "rust" cfg.langtools.languages) (mkMerge [
    (mkIf cfg.langtools.lsp.enable {
      environment.systemPackages = [pkgs.rust-analyzer pkgs.rustfmt];
      tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.rust-tools-nvim];

      tgap.system.programs.neovim.luaExtraConfig = ''
        local rt = require("rust-tools")
        rt.setup({
          server = {
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              -- Hover actions
              vim.keymap.set(
                "n",
                "<C-space>",
                rt.hover_actions.hover_actions,
                {buffer = bufnr}
              )
              -- Code action groups
              vim.keymap.set("n",
                "<leader>a",
                rt.code_action_group.code_action_group,
                {buffer = bufnr}
              )

              -- Default actions
              on_attach(client, bufnr)
            end,
          },
        })

        require("conform").setup({
          formatters_by_ft = {
            rust = {"rustfmt"},
          },
        })
      '';
    })

    (mkIf cfg.langtools.dap.enable {
      environment.systemPackages = [pkgs.lldb];
      tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.plenary-nvim];
    })
  ])
