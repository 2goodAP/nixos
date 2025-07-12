{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim;
  inherit (lib) mkIf optionals optionalString;
in
  mkIf (cfg.enable && cfg.langtools.formatters.enable) {
    programs.neovim = let
      cppEnabled = builtins.elem "cpp" cfg.langtools.languages;
      goEnabled = builtins.elem "go" cfg.langtools.languages;
      hkEnabled = builtins.elem "haskell" cfg.langtools.languages;
      luaEnabled = builtins.elem "lua" cfg.langtools.languages;
      mdEnabled = builtins.elem "markdown" cfg.langtools.languages;
      nixEnabled = builtins.elem "nix" cfg.langtools.languages;
      pyEnabled = builtins.elem "python" cfg.langtools.languages;
      rustEnabled = builtins.elem "rust" cfg.langtools.languages;
      shEnabled = builtins.elem "shell" cfg.langtools.languages;
      sqlEnabled = builtins.elem "sql" cfg.langtools.languages;
      tsEnabled = builtins.elem "typescript" cfg.langtools.languages;
      xmlEnabled = builtins.elem "xml" cfg.langtools.languages;
      zigEnabled = builtins.elem "zig" cfg.langtools.languages;
    in {
      extraPackages = with pkgs;
        [
          bibtex-tidy
          buf
          taplo
          typos
          yq-go
        ]
        ++ optionals cppEnabled [
          llvmPackages.clang-tools
          gersemi
        ]
        ++ optionals goEnabled [
          gofumpt
          goimports-reviser
        ]
        ++ optionals hkEnabled [
          haskellPackages.cabal-fmt
        ]
        ++ optionals luaEnabled [
          stylua
        ]
        ++ optionals nixEnabled [
          alejandra
        ]
        ++ optionals rustEnabled [
          rustfmt
        ]
        ++ optionals shEnabled [
          shellharden
          shfmt
        ]
        ++ optionals sqlEnabled [
          sqlfluff
        ]
        ++ optionals tsEnabled [
          biome
        ]
        ++ optionals xmlEnabled [
          libxml2
        ]
        ++ optionals zigEnabled [
          zig
        ];

      extraPython3Packages = pyPkgs:
        with pyPkgs;
          optionals pyEnabled [
            ruff
          ];

      plugins = with pkgs.vimPlugins; [
        {
          plugin = conform-nvim;
          optional = true;
          type = "lua";
          config = ''
            require("lz.n").load({
              "conform.nvim",
              event = "BufWinEnter",
              keys = {
                {
                  mode = "n", "<leader>lf", function()
                    require("conform").format({async = true})
                  end, silent = true,
                  desc = "Conform: Format buffer",
                },
              },
              after = function()
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
                  formatters = {
            ${
              optionalString cppEnabled ''
                ["clang-format"] = {
                  prepend_args = {
                    "--sort-includes",
                    "--style=google",
                  },
                },
              ''
            }
            ${
              optionalString luaEnabled ''
                stylua = {
                  prepend_args = {
                    "--column-width=88",
                    "--indent-type=Spaces",
                    "--indent-width=2",
                    "--sort-requires",
                  },
                },
              ''
            }
            ${
              optionalString tsEnabled ''
                ["biome-check"] = {
                  args = {
                    "check",
                    "--indent-style=space",
                    "--write",
                    "--stdin-file-path",
                    "$FILENAME",
                  },
                },
              ''
            }
                  },
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
            ${
              optionalString cppEnabled ''
                c = {"clang-format"},
                cpp = {"clang-format"},
                cmake = {"gersemi"},
              ''
            }
            ${
              optionalString goEnabled ''
                go = {"goimports-reviser", "gofumpt"},
              ''
            }
            ${
              optionalString hkEnabled ''
                cabal = {"cabal_fmt"},
              ''
            }
            ${
              optionalString luaEnabled ''
                lua = {"stylua"},
              ''
            }
            ${
              optionalString mdEnabled ''
                markdown = {"typos"},
              ''
            }
            ${
              optionalString nixEnabled ''
                nix = {"alejandra"},
              ''
            }
            ${
              optionalString pyEnabled ''
                python = {
                  "ruff_organize_imports",
                  "ruff_fix",
                  "ruff_format",
                },
              ''
            }
            ${
              optionalString rustEnabled ''
                rust = {"rustfmt"},
              ''
            }
            ${
              optionalString shEnabled ''
                sh = {"shellharden", "shfmt"},
              ''
            }
            ${
              optionalString sqlEnabled ''
                sql = {"sqlfluff"},
              ''
            }
            ${
              optionalString tsEnabled ''
                javascript = {"biome-check"},
                javascriptreact = {"biome-check"},
                json = {"biome-check", "jq", stop_after_first = true},
                jsonc = {"biome-check", "jq", stop_after_first = true},
                typescript = {"biome-check"},
                typescriptreact = {"biome-check"},
              ''
            }
            ${
              optionalString xmlEnabled ''
                xml = {"xmllint"},
              ''
            }
            ${
              optionalString zigEnabled ''
                zir = {"zigfmt"},
                zig = {"zigfmt"},
                zon = {"zigfmt"},
              ''
            }
                  },
                })

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
              end,
            })
          '';
        }
      ];
    };
  }
