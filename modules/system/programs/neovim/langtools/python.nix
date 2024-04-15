{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.system.programs.neovim;
  inherit (lib) mkIf mkMerge optionals optionalString;
in
  mkIf (builtins.elem "python" cfg.langtools.languages) (mkMerge [
    (mkIf cfg.langtools.lsp.enable {
      environment.systemPackages = with pkgs; [
        (python3.withPackages (
          ps:
            (with ps; [
              bandit
              pylsp-mypy
              python-lsp-ruff
              python-lsp-server
              rope
            ])
            ++ (optionals cfg.langtools.dap.enable [ps.debugpy])
        ))
        ruff
      ];

      tgap.system.programs.neovim.luaExtraConfig = ''
        -- Use standard Neovim lsp capabilities.
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        ${optionalString cfg.autocompletion.enable ''
          -- Add additional capabilities supported by nvim-cmp.
          capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
        ''}

        -- Pylsp configuration
        require("lspconfig").pylsp.setup({
          settings = {
            pylsp = {
              plugins = {
                autopep8 = {
                  enabled = false,
                },
                flake8 = {
                  enabled = false,
                },
                mccabe = {
                  enabled = false,
                },
                pycodestyle = {
                  enabled = false,
                },
                pyflakes = {
                  enabled = false,
                },
                pylint = {
                  enabled = false,
                },
                pylsp_mypy = {
                  enabled = true,
                  dmypy = true,
                  live_mode = false,
                  strict = false,
                },
                rope_completion = {
                  enabled = true,
                },
                ruff = {
                  enabled = true,
                },
                yapf = {
                  enabled = false,
                },
              }
            }
          },

          capabilities = capabilities,
          on_attach = function(client, bufnr)
            ${optionalString (!cfg.autocompletion.enable) ''
              -- Enable completion triggered by <c-x><c-o>
              vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            ''}

              -- Mappings.
              -- See `:help vim.lsp.*` for documentation on
              -- any of the below functions.
              local bufopts = {noremap=true, silent=true, buffer=bufnr}
              vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
              vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
              vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
              vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
              vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
              vim.keymap.set(
                "n",
                "<space>wa",
                vim.lsp.buf.add_workspace_folder, bufopts
              )
              vim.keymap.set(
                "n",
                "<space>wr",
                vim.lsp.buf.remove_workspace_folder,
                bufopts
              )
              vim.keymap.set(
                "n",
                "<space>wl",
                function()
                  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end,
                bufopts
              )
              vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
              vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
              vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
              vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
              vim.keymap.set("n", "<space>f", vim.lsp.buf.formatting, bufopts)
            end,
        })
      '';
    })

    (mkIf cfg.langtools.dap.enable {
      tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.nvim-dap-python];

      tgap.system.programs.neovim.luaExtraConfig = ''
        require("dap-python").setup("${pkgs.python3Packages.debugpy}/bin/python")
      '';
    })
  ])
