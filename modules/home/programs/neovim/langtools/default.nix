{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    ./debuggers.nix
    ./formatters.nix
    ./linters.nix
  ];

  options.tgap.home.programs.neovim.langtools = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    debuggers.enable = mkEnableOption "debug-related plugins" // {default = true;};
    formatters.enable = mkEnableOption "format-related plugins" // {default = true;};
    languageServers.enable = mkEnableOption "lsp-related plugins" // {default = true;};
    linters.enable = mkEnableOption "lint-related plugins" // {default = true;};

    languages = mkOption {
      type = types.listOf types.str;
      default = [
        "cpp"
        "go"
        "haskell"
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
        "zig"
      ];
      description = ''
        The extra language servers to be installed. Supported languages are
        "cpp", "go", "haskell", "lisp", "lua", "markdown", "nix", "python",
        "r", "rust", "shell, "sql", "typescript", "xml", "zig".
      '';
    };
  };

  config = let
    cfg = config.tgap.home.programs.neovim;
    osCfg = osConfig.tgap.system.programs;
    inherit (lib) mkIf optionals optionalString;
  in
    mkIf (cfg.enable && cfg.langtools.languageServers.enable) {
      programs.neovim = let
        cppEnabled = builtins.elem "cpp" cfg.langtools.languages;
        goEnabled = builtins.elem "go" cfg.langtools.languages;
        hkEnabled = builtins.elem "haskell" cfg.langtools.languages;
        lispEnabled = builtins.elem "lisp" cfg.langtools.languages;
        luaEnabled = builtins.elem "lua" cfg.langtools.languages;
        mdEnabled = builtins.elem "markdown" cfg.langtools.languages;
        nixEnabled = builtins.elem "nix" cfg.langtools.languages;
        pyEnabled = builtins.elem "python" cfg.langtools.languages;
        rEnabled = builtins.elem "r" cfg.langtools.languages;
        rustEnabled = builtins.elem "rust" cfg.langtools.languages;
        shEnabled = builtins.elem "shell" cfg.langtools.languages;
        sqlEnabled = builtins.elem "sql" cfg.langtools.languages;
        tsEnabled = builtins.elem "typescript" cfg.langtools.languages;
        xmlEnabled = builtins.elem "xml" cfg.langtools.languages;
        zigEnabled = builtins.elem "zig" cfg.langtools.languages;
      in {
        extraPackages = with pkgs;
          [
            harper
          ]
          ++ optionals cppEnabled [
            llvmPackages.clang-tools
            neocmakelsp
          ]
          ++ optionals goEnabled [
            go
            gopls
            golangci-lint-langserver
          ]
          ++ optionals hkEnabled (with haskellPackages; [
            fast-tags
            ghci-dap
            haskell-language-server
            hoogle
          ])
          ++ optionals luaEnabled [
            lua-language-server
          ]
          ++ optionals mdEnabled [
            markdown-oxide
            vale-ls
          ]
          ++ optionals nixEnabled [
            nixd
          ]
          ++ optionals pyEnabled [
            (pkgs.python3.withPackages config.programs.neovim.extraPython3Packages)
          ]
          ++ optionals rEnabled [
            R
            rPackages.languageserver
          ]
          ++ optionals rustEnabled [
            cargo
            graphviz-nox
            rust-analyzer
            rustc
          ]
          ++ optionals shEnabled [
            nodePackages.bash-language-server
          ]
          ++ optionals sqlEnabled [
            sqls
          ]
          ++ optionals tsEnabled [
            typescript
            vscode-json-languageserver
            typescript-styled-plugin
          ]
          ++ optionals xmlEnabled [
            lemminx
          ]
          ++ optionals zigEnabled [
            zls
          ];

        extraPython3Packages = pyPkgs:
          with pyPkgs;
            optionals pyEnabled [
              mypy
              pylsp-mypy
              python-lsp-ruff
              python-lsp-server
              rope
              ruff
            ];

        plugins = let
          lspAugroup = ''"config.lsp"'';
        in
          with pkgs.vimPlugins;
            [
              {
                plugin = nvim-lspconfig;
                type = "lua";
                config = ''
                  require("lz.n").load({
                    "nvim-lspconfig",
                    lazy = false,
                    after = function()
                      -- Create augroup for lsp autocommands
                      vim.api.nvim_create_augroup(${lspAugroup}, {})

                      -- See `:help vim.diagnostic.*` for documentation on
                      -- any of the below functions.
                      -- Icons for diagnostics
                      vim.diagnostic.config({
                        signs = {
                          text = {
                            [vim.diagnostic.severity.ERROR] = "",
                            [vim.diagnostic.severity.WARN] = "",
                            [vim.diagnostic.severity.INFO] = "",
                            [vim.diagnostic.severity.HINT] = "󰌵",
                          },
                        }
                      })

                      -- Keymaps for diagnostics
                      local ls_opts = {silent = true}

                      vim.keymap.set(
                        "n", "<leader>le", vim.diagnostic.open_float,
                        vim.tbl_deep_extend("force", ls_opts,
                          {desc = "Open diagnostic float"})
                      )

                      vim.keymap.set("n", "<leader>l[", function()
                        vim.diagnostic.jump({count = -vim.v.count1})
                      end, vim.tbl_deep_extend("force", ls_opts,
                        {desc = "Jump to previous diagnostic"}))

                      vim.keymap.set("n", "<leader>l]", function()
                        vim.diagnostic.jump({count = vim.v.count1})
                      end, vim.tbl_deep_extend("force", ls_opts,
                        {desc = "Jump to next diagnostic"}))

                      vim.keymap.set(
                        "n", "<leader>lq", vim.diagnostic.setloclist,
                        vim.tbl_deep_extend("force", ls_opts,
                          {desc = "Set diagnostic loc list"})
                      )

                      -- Capabilities and on_attach Keybinds.
                      local capabilities = vim.tbl_deep_extend(
                        "force", vim.lsp.protocol.make_client_capabilities(), {
                          textDocument = {
                            completion = {
                              completionItem = {
                                snippetSupport = true,
                              },
                            },
                            foldingRange = {
                              dynamicRegistration = false,
                              lineFoldingOnly = true,
                            },
                          },
                        }
                      )

                      vim.lsp.config("*", {
                        capabilities = capabilities,
                        on_attach = function(_, bufnr)
                          -- Enable completion triggered by <c-x><c-o>
                          vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"

                          -- Mappings.
                          -- See `:help vim.lsp.*` for documentation on
                          -- any of the below functions.
                          local ls_bufopts = {buffer = bufnr, silent = true}

                          vim.keymap.set(
                            "n", "<leader>la", vim.lsp.buf.code_action,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP code action"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lF", vim.lsp.buf.format,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP format"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lk", vim.lsp.buf.hover,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP hover"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lm", vim.lsp.buf.rename,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP rename"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lD", vim.lsp.buf.declaration,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP declaration"})
                          )

                          vim.keymap.set(
                            "n", "<leader>ls", vim.lsp.buf.signature_help,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP signature help"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lr",
                            require("telescope.builtin").lsp_references,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP references for word under the cursor"})
                          )

                          vim.keymap.set(
                            "n", "<leader>ln",
                            require("telescope.builtin").lsp_incoming_calls,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP incoming calls for word under the cursor"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lo",
                            require("telescope.builtin").lsp_outgoing_calls,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP outgoing calls for word under the cursor"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lu",
                            require("telescope.builtin").lsp_document_symbols,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP document symbols in the current buffer"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lw",
                            require("telescope.builtin").lsp_workspace_symbols,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP document symbols in the current workspace"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lW",
                            require("telescope.builtin").lsp_dynamic_workspace_symbols,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP dynamically list all workspace symbols"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lg", function()
                              require("telescope.builtin").diagnostics({bufnr = 0})
                            end,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP list diagnostics for current buffer"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lG",
                            require("telescope.builtin").diagnostics,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP list diagnostics for all open buffers"})
                          )

                          vim.keymap.set(
                            "n", "<leader>li",
                            require("telescope.builtin").lsp_implementations,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP implementation for word under the cursor"})
                          )

                          vim.keymap.set(
                            "n", "<leader>ld",
                            require("telescope.builtin").lsp_definitions,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP definition for word under the cursor"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lt",
                            require("telescope.builtin").lsp_type_definitions,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP type definition for word under the cursor"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lA", vim.lsp.buf.add_workspace_folder,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP add workspace folder"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lR", vim.lsp.buf.remove_workspace_folder,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP remove workspace folder"})
                          )

                          vim.keymap.set(
                            "n", "<leader>lL", function()
                              vim.print(vim.lsp.buf.list_workspace_folders())
                            end,
                            vim.tbl_deep_extend("force", ls_bufopts,
                              {desc = "LSP list workspace folders"})
                          )
                        end
                      })

                      -- Configurations for individual language servers
                      vim.lsp.enable("harper_ls")
                      vim.lsp.config("harper_ls", {
                        settings = {
                          ["harper-ls"] = {
                            userDictPath = "${config.xdg.dataHome}/harper/user_dict.txt",
                          },
                        },
                      })
                  ${
                    optionalString cppEnabled ''
                      vim.lsp.enable("clangd")
                      vim.lsp.enable("neocmake")
                    ''
                  }
                  ${
                    optionalString goEnabled ''
                      vim.lsp.enable("gopls")
                      vim.lsp.enable("golangci_lint_ls")
                    ''
                  }
                  ${
                    optionalString luaEnabled ''
                      vim.lsp.enable("lua_ls")
                      vim.lsp.config("lua_ls", {
                        settings = {
                          Lua = {
                            runtime = {
                              -- Tell the language server which version of Lua
                              -- (most likely LuaJIT in the case of Neovim).
                              version = "LuaJIT",
                            },
                            diagnostics = {
                              -- Get the language server to recognize the `vim` global.
                              globals = {"vim"},
                            },
                            workspace = {
                              -- Make the server aware of Neovim runtime files.
                              library = vim.api.nvim_get_runtime_file("", true),
                            },
                            -- Do not send telemetry data containing a
                            -- randomized but unique identifier.
                            telemetry = {
                              enable = false,
                            },
                          },
                        },
                      })
                    ''
                  }
                  ${
                    optionalString mdEnabled ''
                      vim.lsp.enable("markdown_oxide")
                      vim.lsp.enable("vale_ls")
                    ''
                  }
                  ${
                    optionalString nixEnabled ''
                      vim.lsp.enable("nixd")
                    ''
                  }
                  ${
                    optionalString rEnabled ''
                      vim.lsp.enable("r_language_server")
                    ''
                  }
                  ${
                    optionalString pyEnabled ''
                      vim.lsp.enable("pylsp")
                      vim.lsp.config("pylsp", {
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
                      })
                    ''
                  }
                  ${
                    optionalString shEnabled ''
                      vim.lsp.enable("bashls")
                      ${optionalString (osCfg.defaultShell == "nushell") ''
                        vim.lsp.enable("nushell")
                      ''}
                    ''
                  }
                  ${
                    optionalString sqlEnabled ''
                      vim.lsp.enable("sqls")
                    ''
                  }
                  ${
                    optionalString tsEnabled ''
                      vim.lsp.enable("jsonls")
                    ''
                  }
                  ${
                    optionalString xmlEnabled ''
                      vim.lsp.enable("lemminx")
                    ''
                  }
                  ${
                    optionalString zigEnabled ''
                      vim.lsp.enable("zls")
                    ''
                  }
                    end,
                  })
                '';
                runtime = builtins.listToAttrs (
                  map (lang: {
                    name = "ftplugin/${lang}.lua";
                    value = {text = "vim.bo.tabstop = 2";};
                  }) [
                    "cpp"
                    "javascript"
                    "javascriptreact"
                    "json"
                    "jsonc"
                    "lua"
                    "nix"
                    "typescript"
                    "typescriptreact"
                    "xml"
                    "yuck"
                  ]
                );
              }

              {
                plugin = lsp_signature-nvim;
                optional = true;
                type = "lua";
                config = ''
                  require("lz.n").load({
                    "lsp_signature.nvim",
                    event = "InsertEnter",
                    after = function()
                      require("lsp_signature").setup({
                        bind = true, -- This is mandatory.
                        handler_opts = {
                          border = "rounded"
                        }
                      })
                    end,
                  })
                '';
              }
            ]
            ++ optionals cppEnabled [
              {
                plugin = clangd_extensions-nvim;
                optional = true;
                type = "lua";
                config = ''
                  require("lz.n").load({
                    "clangd_extensions.nvim",
                    ft = {"c", "cpp"},
                  })
                '';
              }
            ]
            ++ optionals hkEnabled [
              {
                plugin = haskell-tools-nvim;
                optional = true;
                type = "lua";
                config = let
                  ft = ''"haskell"'';
                in ''
                  require("lz.n").load({
                    "haskell-tools.nvim",
                    ft = ${ft},
                    after = function()
                      vim.api.nvim_create_autocmd("FileType", {
                        group = ${lspAugroup},
                        desc = "Create custom debugger keymaps for python filetypes",
                        pattern = { ${ft} },
                        callback = function()
                          vim.schedule(function()
                            local ht = require("haskell-tools")
                            local ht_bufopts = {
                              buffer = vim.api.nvim_get_current_buf(),
                              silent = true,
                            }

                            -- haskell-language-server relies heavily on codelenses,
                            -- so auto-refresh (see advanced configuration)
                            -- is enabled by default
                            vim.keymap.set(
                              "n", "<leader>kr", vim.lsp.codelens.run,
                              vim.tbl_deep_extend("force", ht_bufopts,
                                {desc = "Haskell codelens run"})
                            )

                            -- Hoogle search for the type signature of
                            -- the definition under the cursor
                            vim.keymap.set(
                              "n", "<space>ks", ht.hoogle.hoogle_signature,
                              vim.tbl_deep_extend("force", ht_bufopts,
                                {desc = "Haskell hoogle search for type signature"})
                            )

                            -- Evaluate all code snippets
                            vim.keymap.set(
                              "n", "<space>ke", ht.lsp.buf_eval_all,
                              vim.tbl_deep_extend("force", ht_bufopts,
                                {desc = "Haskell buffer eval all code snippets"})
                            )

                            -- Toggle a GHCi repl for the current package
                            vim.keymap.set(
                              "n", "<leader>kp", ht.repl.toggle,
                              vim.tbl_deep_extend("force", ht_bufopts,
                                {desc = "Haskell GHCi repl toggle for current package"})
                            )

                            -- Toggle a GHCi repl for the current buffer
                            vim.keymap.set("n", "<leader>kb", function()
                              ht.repl.toggle(vim.api.nvim_buf_get_name(0))
                            end, vim.tbl_deep_extend("force", ht_bufopts, {
                              desc = "Haskell GHCi repl toggle for current buffer"
                            }))

                            vim.keymap.set(
                              "n", "<leader>kq", ht.repl.quit,
                              vim.tbl_deep_extend("force", ht_bufopts,
                                {desc = "Haskell GHCi repl quit"})
                            )
                          end)
                        end,
                      })
                    end,
                  })
                '';
              }
            ]
            ++ optionals lispEnabled [
              {
                plugin = parinfer-rust;
                optional = true;
                type = "lua";
                config = ''
                  require("lz.n").load({
                    "parinfer-rust",
                    ft = {"clojure", "hy", "lisp", "scheme", "yuck"},
                  })
                '';
              }
            ]
            ++ optionals luaEnabled [
              {
                plugin = lazydev-nvim;
                optional = true;
                type = "lua";
                config = ''
                  require("lz.n").load({
                    "lazydev.nvim",
                    ft = "lua",
                    after = function()
                      require("lazydev").setup({
                        library = {
                          -- Load luvit types when `vim.uv` word is found
                          {path = "''${3rd}/luv/library", words = {"vim%.uv"}},
                          -- Load lz.n types when `lz.n` module is required
                          {path = "lz.n", mods = {"lz.n"}},
                  ${
                    optionalString cfg.langtools.debuggers.enable ''
                      -- Load nvim-dap-ui types when `dapui` module is required
                      {path = "nvim-dap-ui", mods = {"dapui"}},
                    ''
                  }
                        },
                      })
                    end,
                  })
                '';
              }
            ]
            ++ optionals rustEnabled [
              {
                plugin = pkgs.vimPlugins.rustaceanvim;
                optional = true;
                type = "lua";
                config = let
                  ft = ''"rust"'';
                in ''
                  require("lz.n").load({
                    "rustaceanvim",
                    ft = ${ft},
                    after = function()
                      vim.api.nvim_create_autocmd("FileType", {
                        group = ${lspAugroup},
                        desc = "Create custom debugger keymaps for python filetypes",
                        pattern = { ${ft} },
                        callback = function()
                          vim.schedule(function()
                            vim.keymap.set("n", "<leader>la", function()
                               -- Supports rust-analyzer's grouping
                                vim.cmd.RustLsp("codeAction")
                            end, {
                              buffer = vim.api.nvim_get_current_buf(),
                              silent = true,
                              desc = "Rustacean run code action",
                            })
                          end)
                        end,
                      })
                    end,
                  })
                '';
              }
            ]
            ++ optionals tsEnabled [
              {
                plugin = typescript-tools-nvim;
                optional = true;
                type = "lua";
                config = ''
                  require("lz.n").load({
                    "typescript-tools.nvim",
                    ft = {
                      "javascript",
                      "javascriptreact",
                      "typescript",
                      "typescriptreact",
                    },
                    after = function()
                      require("typescript-tools").setup({
                        on_attach = function()
                          vim.keymap.set(
                            "n", "<leader>yo", "<Cmd>TSToolsOrganizeImports<CR>",
                            {desc = "TS tools sort and remove unused imports"}
                          )

                          vim.keymap.set(
                            "n", "<leader>yS", "<Cmd>TSToolsSortImports<CR>",
                            {desc = "TS tools sort imports"}
                          )

                          vim.keymap.set(
                            "n", "<leader>yU", "<Cmd>TSToolsRemoveUnusedImports<CR>",
                            {desc = "TS tools remove unused inputs"}
                          )

                          vim.keymap.set(
                            "n", "<leader>yu", "<Cmd>TSToolsRemoveUnused<CR>",
                            {desc = "TS tools remove all unused statements"}
                          )

                          vim.keymap.set(
                            "n", "<leader>ya", "<Cmd>TSToolsAddMissingImports<CR>",
                            {desc = "TS tools add absent imports for all statements"}
                          )

                          vim.keymap.set(
                            "n", "<leader>yf", "<Cmd>TSToolsFixAll<CR>",
                            {desc = "TS tools fix all fixable errors"}
                          )

                          vim.keymap.set(
                            "n", "<leader>yg", "<Cmd>TSToolsGoToSourceDefinition<CR>",
                            {desc = "TS tools go to source definition"}
                          )

                          vim.keymap.set(
                            "n", "<leader>ym", "<Cmd>TSToolsRenameFile<CR>",
                            {desc = "TS tools rename current file and propagate changes"}
                          )

                          vim.keymap.set(
                            "n", "<leader>yr", "<Cmd>TSToolsFileReferences<CR>",
                            {desc = "TS tools find files that reference current file"}
                          )
                        end,
                        settings = {
                          tsserver_file_preferences = {
                            includeInlayParameterNameHints = "all",
                            includeCompletionsForModuleExports = true,
                            quotePreference = "auto",
                          },
                          tsserver_format_options = {
                            allowIncompleteCompletions = false,
                            allowRenameOfImportPath = false,
                          },
                          tsserver_plugins = {
                            -- for TypeScript v4.9+
                            "@styled/typescript-styled-plugin",
                          },
                        },
                      })
                    end,
                  })
                '';
              }
            ];
      };
    };
}
