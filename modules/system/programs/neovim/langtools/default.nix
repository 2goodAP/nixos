{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./cpp.nix
    ./go.nix
    ./haskell.nix
    ./lua.nix
    ./markdown.nix
    ./nix.nix
    ./python.nix
    ./r.nix
    ./rust.nix
    ./shell.nix
    ./sql.nix
    ./typescript.nix
  ];

  options.tgap.system.programs.neovim.langtools = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    dap.enable = mkEnableOption "Whether or not to enable dap-related plugins.";

    languages = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        The extra language servers to be installed. Supported languages are
        "cpp", "go", "haskell", "lua", "markdown", "nix",
        "python", "r", "rust", "shell, "sql", "typescript".
      '';
    };

    lsp = {
      enable = mkEnableOption "Whether or not to enable lsp-related plugins.";
      lspsaga.enable = mkEnableOption "Whether or not to enable lspsaga.nvim.";
      lspSignature.enable = mkEnableOption "Whether or not to enable lsp-signature.nvim.";
      ufo.enable = mkEnableOption "Whether or not to enable ufo.nvim.";
    };
  };

  config = let
    cfg = config.tgap.system.programs.neovim;
    inherit (lib) mkIf mkMerge optionals optionalString;
  in
    mkMerge [
      (mkIf cfg.langtools.dap.enable {
        tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.nvim-dap];
      })

      (mkIf cfg.langtools.lsp.enable {
        environment.systemPackages = with pkgs; [
          bibtex-tidy
          buf
          checkmake
          gawk
          gitlint
          hadolint
          rstcheck
          taplo
          texlivePackages.chktex
          typos
          vale
          yamllint
          yq-go
        ];

        tgap.system.programs.neovim.startPackages =
          (with pkgs.vimPlugins; [
            conform-nvim
            nvim-lspconfig
            nvim-lint
          ])
          ++ (
            optionals cfg.langtools.lsp.lspsaga.enable [pkgs.vimPlugins.lspsaga-nvim]
          )
          ++ (
            optionals cfg.langtools.lsp.lspSignature.enable [pkgs.vimPlugins.lsp_signature-nvim]
          )
          ++ (
            optionals cfg.langtools.lsp.ufo.enable [pkgs.vimPlugins.nvim-ufo]
          );

        tgap.system.programs.neovim.luaExtraConfigEarly = ''
          -- Use standard Neovim lsp capabilities.
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          ${optionalString cfg.autocompletion.enable ''
            -- Add additional capabilities supported by nvim-cmp.
            capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
          ''}

          local function _set_lsp_keymaps(bufnr)
          ${optionalString (!cfg.autocompletion.enable) ''
            -- Enable completion triggered by <c-x><c-o>
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
          ''}

            -- Mappings.
            -- See `:help vim.lsp.*` for documentation on
            -- any of the below functions.
            local function _tab_set_key(tab, key, val)
              tab[key] = val
              return tab
            end
            local bufopts = {noremap=true, silent=true, buffer=bufnr}

            vim.keymap.set(
              "n", "gD", vim.lsp.buf.declaration,
              _tab_set_key(bufopts, "desc", "LSP: Declaration")
            )
            vim.keymap.set(
              "n", "gd", vim.lsp.buf.definition,
              _tab_set_key(bufopts, "desc", "LSP: Definition")
            )
            vim.keymap.set(
              "n", "K", vim.lsp.buf.hover,
              _tab_set_key(bufopts, "desc", "LSP: Hover")
            )
            vim.keymap.set(
              "n", "gI", vim.lsp.buf.implementation,
              _tab_set_key(bufopts, "desc", "LSP: Implementation")
            )
            vim.keymap.set(
              "n", "<C-k>", vim.lsp.buf.signature_help,
              _tab_set_key(bufopts, "desc", "LSP: Signature help")
            )
            vim.keymap.set(
              "n", "<leader>wa", vim.lsp.buf.add_workspace_folder,
              _tab_set_key(bufopts, "desc", "LSP: Add workspace folder")
            )
            vim.keymap.set(
              "n", "<leader>wr", vim.lsp.buf.remove_workspace_folder,
              _tab_set_key(bufopts, "desc", "LSP: Remove workspace folder")
            )
            vim.keymap.set(
              "n", "<leader>wl", function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
              end,
              _tab_set_key(bufopts, "desc", "LSP: List workspace folders")
            )
            vim.keymap.set(
              "n", "<leader>D", vim.lsp.buf.type_definition,
              _tab_set_key(bufopts, "desc", "LSP: Type definition")
            )
            vim.keymap.set(
              "n", "<leader>rn", vim.lsp.buf.rename,
              _tab_set_key(bufopts, "desc", "LSP: Rename")
            )
            vim.keymap.set(
              "n", "<leader>ca", vim.lsp.buf.code_action,
              _tab_set_key(bufopts, "desc", "LSP: Code action")
            )
            vim.keymap.set(
              "n", "gr", vim.lsp.buf.references,
              _tab_set_key(bufopts, "desc", "LSP: References")
            )
            vim.keymap.set(
              "n", "<leader>F", vim.lsp.buf.format,
              _tab_set_key(bufopts, "desc", "LSP: Format")
            )
          end
        '';

        tgap.system.programs.neovim.luaExtraConfig = ''
          -- Mappings.
          -- See `:help vim.diagnostic.*` for documentation on
          -- any of the below functions.
          local opts = {noremap=true, silent=true}
          vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

          -- conform + nvim-lint
          require("conform").setup({
            formatters_by_ft = {
              ["*"] = {{"typos", "trim_newlines", "trim_whitespace"}},
              bibtex = {"bibtex-tidy"},
              proto = {"buf"},
              toml = {"taplo"},
              yaml = {"yq"},
            },
            format_on_save = {
              -- These options will be passed to conform.format()
              timeout_ms = 500,
              lsp_fallback = true,
            },
          })

          require('lint').linters_by_ft = {
            asciidoc = {"vale"},
            Dockerfile = {"hadolint"},
            gitcommit = {"gitlint"},
            html = {"vale"},
            make = {"checkmake"},
            org = {"vale"},
            proto = {"buf_lint"},
            plaintex = {"chktex"},
            rst = {{"rstcheck", "vale"}},
            tex = {"chktex"},
            xml = {"vale"},
            yaml = {"yamllint"},
          }

          vim.api.nvim_create_autocmd({"BufWritePost"}, {
            callback = function()
              -- try_lint without arguments runs the linters defined in
              -- `linters_by_ft` for the current filetype
              require("lint").try_lint()
            end,
          })

          -- Other lsp tools
          ${optionalString cfg.langtools.lsp.lspsaga.enable ''
            require("lspsaga").setup({})
          ''}

          ${optionalString cfg.langtools.lsp.lspSignature.enable ''
            require "lsp_signature".setup({
              bind = true, -- This is mandatory.
              handler_opts = {
                border = "rounded"
              }
            })
          ''}

          ${optionalString cfg.langtools.lsp.ufo.enable ''
            vim.o.foldcolumn = "1" -- "0" is not bad
            vim.o.foldlevel = 99 -- Using ufo provider need a large value
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            -- Using ufo provider need remap `zR` and `zM`.
            vim.keymap.set("n", "zR", require("ufo").openAllFolds)
            vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

            -- Using nvim lsp as LSP client
            -- Tell the server the capability of foldingRange,
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true
            }
            local servers = require("lspconfig").util.available_servers()
            for _, ls in ipairs(servers) do
                require("lspconfig")[ls].setup({
                  capabilities = capabilities
                })
            end
            require("ufo").setup()
          ''}
        '';
      })
    ];
}
