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

  options.tgap.home.programs.neovim.langtools = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    dap.enable = mkEnableOption "dap-related plugins";

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
      enable = mkEnableOption "lsp-related plugins";
      lspsaga.enable = mkEnableOption "lspsaga.nvim";
      lspSignature.enable = mkEnableOption "lsp-signature.nvim";
      ufo.enable = mkEnableOption "ufo.nvim";
    };
  };

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf mkMerge optionals optionalString;
  in
    mkMerge [
      (mkIf cfg.langtools.dap.enable {
        programs.neovim.plugins = [pkgs.vimPlugins.nvim-dap];
      })

      (mkIf cfg.langtools.lsp.enable {
        home.file."${cfg.runtimepath}/lua/tgap/lsp-utils.lua".text = ''
          -- Use standard Neovim lsp capabilities.
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          ${optionalString cfg.autocompletion.enable ''
            -- Add additional capabilities supported by nvim-cmp.
            capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
          ''}

          local M = {}
          M.capabilities = capabilities
          M.set_lsp_keymaps = function(bufnr)
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
            local bufopts = {buffer = bufnr, silent = true}

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
              "n", "<leader>T", vim.lsp.buf.format,
              _tab_set_key(bufopts, "desc", "LSP: Format")
            )
          end

          return M
        '';

        programs.neovim = {
          extraPackages = with pkgs; [
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

          plugins =
            (with pkgs.vimPlugins; [
              nvim-lspconfig
              {
                plugin = conform-nvim;
                type = "lua";
                config = ''
                  local format_opts = {
                    -- Extra options passed to conform.format()
                    timeout_ms = 500,
                    lsp_format = "fallback",
                  }

                  require("conform").setup({
                    default_format_opts = format_opts,
                    format_after_save = function(bufnr)
                      -- Disable with a global or buffer-local variable
                      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                        return
                      end
                      return format_opts
                    end,
                    formatters_by_ft = {
                      ["*"] = {"trim_newlines", "trim_whitespace"},
                      asciidoc = {"typos"},
                      bibtex = {"bibtex-tidy"},
                      html = {"typos"},
                      norg = {"typos"},
                      org = {"typos"},
                      proto = {"buf"},
                      rst = {"typos"},
                      text = {"typos"},
                      toml = {"taplo"},
                      yaml = {"yq"},
                    },
                  })

                  vim.keymap.set(
                    "", "<leader>F", function()
                      require("conform").format({async = true})
                    end, {
                      desc = "Conform: Format buffer",
                      silent = true,
                    }
                  )

                  vim.api.nvim_create_user_command("FormatDisable", function(args)
                    if args.bang then
                      -- FormatDisable! will disable formatting just for this buffer
                      vim.b.disable_autoformat = true
                    else
                      vim.g.disable_autoformat = true
                    end
                  end, {
                    desc = "Disable autoformat-on-save",
                    bang = true,
                  })
                  vim.api.nvim_create_user_command("FormatEnable", function()
                    vim.b.disable_autoformat = false
                    vim.g.disable_autoformat = false
                  end, {
                    desc = "Re-enable autoformat-on-save",
                  })
                '';
              }
              {
                plugin = nvim-lint;
                type = "lua";
                config = ''
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
                    tex = {{"chktex", "vale"}},
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
                '';
              }
            ])
            ++ optionals cfg.langtools.lsp.lspsaga.enable [
              {
                plugin = pkgs.vimPlugins.lspsaga-nvim;
                type = "lua";
                config = "require('lspsaga').setup({})";
              }
            ]
            ++ optionals cfg.langtools.lsp.lspSignature.enable [
              {
                plugin = pkgs.vimPlugins.lsp_signature-nvim;
                type = "lua";
                config = ''
                  require "lsp_signature".setup({
                    bind = true, -- This is mandatory.
                    handler_opts = {
                      border = "rounded"
                    }
                  })
                '';
              }
            ]
            ++ optionals cfg.langtools.lsp.ufo.enable [
              {
                plugin = pkgs.vimPlugins.nvim-ufo;
                type = "lua";
                config = ''
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
                '';
              }
            ];

          extraLuaConfig = ''
            -- Mappings.
            -- See `:help vim.diagnostic.*` for documentation on
            -- any of the below functions.
            local opts = {silent = true}
            vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
            vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)
          '';
        };
      })
    ];
}
