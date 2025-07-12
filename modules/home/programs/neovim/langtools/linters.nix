{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim;
  inherit (lib) mkIf optionals optionalAttrs optionalString;
in
  mkIf (cfg.enable && cfg.langtools.linters.enable) {
    programs.neovim = let
      cppEnabled = builtins.elem "cpp" cfg.langtools.languages;
      goEnabled = builtins.elem "go" cfg.langtools.languages;
      hkEnabled = builtins.elem "haskell" cfg.langtools.languages;
      luaEnabled = builtins.elem "lua" cfg.langtools.languages;
      mdEnabled = builtins.elem "markdown" cfg.langtools.languages;
      nixEnabled = builtins.elem "nix" cfg.langtools.languages;
      pyEnabled = builtins.elem "python" cfg.langtools.languages;
      shEnabled = builtins.elem "shell" cfg.langtools.languages;
      sqlEnabled = builtins.elem "sql" cfg.langtools.languages;
      tsEnabled = builtins.elem "typescript" cfg.langtools.languages;
      xmlEnabled = builtins.elem "xml" cfg.langtools.languages;
      zigEnabled = builtins.elem "zig" cfg.langtools.languages;
    in {
      extraPackages = with pkgs;
        [
          checkmake
          texlivePackages.chktex
          gitlint
          hadolint
          rstcheck
          vale
          yamllint
        ]
        ++ optionals cppEnabled [
          llvmPackages.clang-tools
          flawfinder
        ]
        ++ optionals goEnabled [
          golangci-lint
        ]
        ++ optionals hkEnabled [
          haskellPackages.hlint
        ]
        ++ optionals luaEnabled [
          selene
        ]
        ++ optionals mdEnabled [
          markdownlint-cli2
        ]
        ++ optionals nixEnabled [
          deadnix
        ]
        ++ optionals shEnabled [
          dotenv-linter
          shellcheck
        ]
        ++ optionals sqlEnabled [
          sqlfluff
        ]
        ++ optionals tsEnabled [
          biome
        ]
        ++ optionals zigEnabled [
          zig-zlint
        ];

      extraPython3Packages = pyPkgs:
        with pyPkgs;
          optionals pyEnabled [
            bandit
            mypy
            ruff
            vulture
          ];

      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-lint;
          optional = true;
          type = "lua";
          config = ''
            require("lz.n").load({
              "nvim-lint",
              event = "BufWinEnter",
              after = function()
            ${
              optionalString cppEnabled ''
                require("lint").linters.clangtidy.args = {
                  "--checks=boost-*,bugprone-*,clang-analyzer-*,concurrency-*",
                  "--checks=cppcoreguidelines-*,google-*,modernize-*,misc-*,mpi-*",
                  "--checks=openmp-*,performance-*,portability-*,readibility-*",
                  "--format-style=google",
                  "--quiet",
                }
              ''
            }

            ${
              optionalString shEnabled ''
                vim.filetype.add({
                  -- Detect and apply filetypes based on the entire filename
                  filename = {
                    [".env"] = "dotenv",
                    ["env"] = "dotenv",
                  },
                  -- Detect and apply filetypes based on certain patterns
                  pattern = {
                    -- INFO: Match filenames like - ".env.example", ".env.local", etc.
                    ["%.env%.[%w_.-]+"] = "dotenv",
                  },
                })
              ''
            }

                require("lint").linters_by_ft = {
                  asciidoc = {"vale"},
                  Dockerfile = {"hadolint"},
                  gitcommit = {"gitlint"},
                  html = {"vale"},
                  make = {"checkmake"},
                  org = {"vale"},
                  proto = {"buf_lint"},
                  plaintex = {"chktex"},
                  rst = {"rstcheck", "vale"},
                  tex = {"chktex", "vale"},
                  yaml = {"yamllint"},
            ${
              optionalString cppEnabled ''
                c = {"clangtidy"},
                cpp = {"clangtidy", "flawfinder"},
              ''
            }
            ${
              optionalString goEnabled ''
                go = {"golangcilint"},
              ''
            }
            ${
              optionalString hkEnabled ''
                haskell = {"hlint"},
              ''
            }
            ${
              optionalString luaEnabled ''
                lua = {"selene"},
              ''
            }
            ${
              optionalString mdEnabled ''
                markdown = {"markdownlint-cli2", "vale"},
              ''
            }
            ${
              optionalString nixEnabled ''
                nix = {"nix", "deadnix"},
              ''
            }
            ${
              optionalString pyEnabled ''
                python = {"ruff", "mypy", "vulture", "bandit"},
              ''
            }
            ${
              optionalString shEnabled ''
                dotenv = {"dotenv_linter"},
                sh = {"shellcheck"},
              ''
            }
            ${
              optionalString sqlEnabled ''
                sql = {"sqlfluff"},
              ''
            }
            ${
              optionalString tsEnabled ''
                javascript = {"biome"},
                javascriptreact = {"biome"},
                json = {"biome"},
                jsonc = {"biome"},
                typescript = {"biome"},
                typescriptreact = {"biome"},
              ''
            }
            ${
              optionalString xmlEnabled ''
                xml = {"vale"},
              ''
            }
                }

                vim.api.nvim_create_autocmd("BufWrite", {
                  desc = "nvim-lint autocmd to trigger linting",
                  callback = function()
                    -- try_lint without arguments runs the linters defined in
                    -- `linters_by_ft` for the current filetype
                    require("lint").try_lint()
                  end,
                })
              end,
            })
          '';
          runtime = optionalAttrs luaEnabled {
            "selene.toml".text = ''
              std = "vim"

              [lints]
              mixed_table = "allow"
            '';
          };
        }
      ];
    };
  }
