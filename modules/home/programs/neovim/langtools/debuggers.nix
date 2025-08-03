{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tgap.home.programs.neovim;
  inherit (lib) getExe mkIf optionals optionalString;
in
  mkIf (cfg.enable && cfg.langtools.debuggers.enable) {
    programs.neovim = let
      cppEnabled = builtins.elem "cpp" cfg.langtools.languages;
      goEnabled = builtins.elem "go" cfg.langtools.languages;
      hkEnabled = builtins.elem "haskell" cfg.langtools.languages;
      luaEnabled = builtins.elem "lua" cfg.langtools.languages;
      pyEnabled = builtins.elem "python" cfg.langtools.languages;
      rustEnabled = builtins.elem "rust" cfg.langtools.languages;
      shEnabled = builtins.elem "shell" cfg.langtools.languages;
      tsEnabled = builtins.elem "typescript" cfg.langtools.languages;

      bashDb = pkgs.bashdb;
      cppTools = pkgs.vscode-extensions.ms-vscode.cpptools;
      gDb = pkgs.gdb;
      vscodeBashDebug = pkgs.vscode-bash-debug;
      vscodeJsDebug = pkgs.vscode-js-debug;
    in {
      extraLuaPackages = luaPkgs:
        optionals luaEnabled [
          luaPkgs.nlua
        ];

      extraPackages = with pkgs;
        optionals (cppEnabled || rustEnabled) [
          cppTools
          gDb
          rr
        ]
        ++ optionals goEnabled [
          delve
        ]
        ++ optionals hkEnabled [
          haskellPackages.haskell-debug-adapter
        ]
        ++ optionals shEnabled [
          bashDb
          vscodeBashDebug
        ]
        ++ optionals tsEnabled [
          nodejs
          vscodeJsDebug
        ];

      extraPython3Packages = pyPkgs:
        with pyPkgs;
          optionals pyEnabled [
            debugpy
            pytest
          ];

      plugins = let
        dapAugroup = ''"config.dap"'';
      in
        with pkgs.vimPlugins;
          [
            {
              plugin = nvim-dap;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "nvim-dap",
                  event = "BufWinEnter",
                  after = function()
                    -- Create an autogroup for dap keymaps
                    vim.api.nvim_create_augroup(${dapAugroup}, {})

                    local dap = require("dap")

                    dap.adapters = {
                ${
                  optionalString (cppEnabled || rustEnabled) ''
                    cppdbg = {
                      id = "cppdbg",
                      type = "executable",
                      name = "VSCode C/C++ debugger",
                      command = "${cppTools}/share/vscode/extensions/" ..
                        "${cppTools.vscodeExtUniqueId}/debugAdapters/bin/OpenDebugAD7",
                    },
                  ''
                }
                ${
                  optionalString luaEnabled ''
                    nlua = function(callback, config)
                      callback({
                        type = "server",
                        host = config.host or "127.0.0.1",
                        port = config.port or 8086,
                      })
                    end,
                  ''
                }
                ${
                  optionalString shEnabled ''
                    bashdb = {
                      type = "executable",
                      command = "node",
                      args = {
                        "${vscodeBashDebug}/share/vscode/extensions/" ..
                        "${vscodeBashDebug.vscodeExtUniqueId}/out/bashDebug.js",
                      },
                      name = "bashdb",
                    },
                  ''
                }
                ${
                  optionalString tsEnabled ''
                    ["pwa-node"] = {
                      type = "server",
                      host = "127.0.0.1",
                      port = "''${port}",
                      executable = {
                        command = "node",
                        -- Make sure to update this path to point to your installation
                        args = {
                          "${vscodeJsDebug}/src/dapDebugServer.js",
                          "''${port}",
                        },
                      },
                    },
                  ''
                }
                    }

                    dap.configurations = {
                ${
                  optionalString luaEnabled ''
                    lua = {
                      {
                        type = "nlua",
                        request = "attach",
                        name = "Attach to running Neovim instance",
                      },
                    },
                  ''
                }
                ${
                  optionalString shEnabled ''
                    sh = {
                      {
                        type = "bashdb",
                        request = "launch",
                        name = "Launch file",
                        showDebugOutput = true,
                        pathBashdb = "${getExe bashDb}",
                        pathBashdbLib = "${bashDb}/share/bashdb",
                        trace = true,
                        file = "''${file}",
                        program = "''${file}",
                        cwd = "''${workspaceFolder}",
                        pathCat = "cat",
                        pathBash = "${getExe pkgs.bash}",
                        pathMkfifo = "mkfifo",
                        pathPkill = "pkill",
                        args = {},
                        env = {},
                        terminalKind = "integrated",
                      },
                    },
                  ''
                }
                    }

                ${
                  optionalString (cppEnabled || rustEnabled) ''
                    for _, ft in ipairs({"c", "cpp", "rust"}) do
                      dap.configurations[ft] = {
                        {
                          stopAtEntry = true,
                          name = "Launch file",
                          type = "cppdbg",
                          request = "launch",
                          cwd = "''${workspaceFolder}",
                          program = function()
                            return vim.fn.input(
                              "Path to executable: ",
                              vim.fn.getcwd() .. "/",
                              "file"
                            )
                          end,
                          setupCommands = {
                            {
                               text = "-enable-pretty-printing",
                               description = "enable pretty printing",
                               ignoreFailures = false,
                            },
                          },
                        },
                        {
                          name = "Attach to gdbserver :1234",
                          type = "cppdbg",
                          request = "launch",
                          MIMode = "gdb",
                          miDebuggerServerAddress = "127.0.0.1:1234",
                          miDebuggerPath = "${getExe gDb}",
                          cwd = "''${workspaceFolder}",
                          program = function()
                            return vim.fn.input(
                              "Path to executable: ",
                              vim.fn.getcwd() .. "/",
                              "file"
                            )
                          end,
                          setupCommands = {
                            {
                               text = "-enable-pretty-printing",
                               description = "enable pretty printing",
                               ignoreFailures = false,
                            },
                          },
                        },
                      }
                    end
                  ''
                }

                ${
                  optionalString tsEnabled ''
                    for _, ft in ipairs({
                      "javascript",
                      "typescript",
                      "javascriptreact",
                      "typescriptreact",
                    }) do
                      dap.configurations[ft] = {
                        {
                          type = "pwa-node",
                          request = "launch",
                          name = "Launch file",
                          program = "''${file}",
                          cwd = "''${workspaceFolder}",
                        },
                      }
                    end
                  ''
                }

                    -- Debugger Keymaps
                    vim.keymap.set(
                      "n", "<leader>dt", dap.terminate,
                      {silent = true, desc = "DAP terminate program"}
                    )

                    vim.keymap.set(
                      "n", "<leader>db", dap.toggle_breakpoint,
                      {silent = true, desc = "DAP toggle breakpoint"}
                    )

                    vim.keymap.set(
                      "n", "<leader>dc", dap.continue,
                      {silent = true, desc = "DAP continue program execution"}
                    )

                    vim.keymap.set(
                      "n", "<leader>dv", dap.step_over,
                      {silent = true, desc = "DAP step over functions"}
                    )

                    vim.keymap.set(
                      "n", "<leader>do", dap.step_out,
                      {silent = true, desc = "DAP step out of functions"}
                    )

                    vim.keymap.set(
                      "n", "<leader>di", dap.step_into,
                      {silent = true, desc = "DAP step into functions"}
                    )

                    vim.keymap.set(
                      "n", "<leader>dp", dap.pause,
                      {silent = true, desc = "DAP pause execution"}
                    )

                    vim.keymap.set(
                      "n", "<leader>dd", dap.down,
                      {silent = true, desc = "DAP go down"}
                    )

                    vim.keymap.set(
                      "n", "<leader>du", dap.up,
                      {silent = true, desc = "DAP go up"}
                    )

                    vim.keymap.set(
                      "n", "<leader>dr", dap.repl.open,
                      {silent = true, desc = "DAP inspect state via built-in REPL"}
                    )
                  end,
                })
              '';
            }

            nvim-nio
            {
              plugin = nvim-dap-ui;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "nvim-dap-ui",
                  event = "BufWinEnter",
                  before = function()
                    require("lz.n").trigger_load("nvim-dap")
                  end,
                  after = function()
                    local dap, dapui = require("dap"), require("dapui")

                    dapui.setup()
                    dap.listeners.before.attach.dapui_config = dapui.open
                    dap.listeners.before.launch.dapui_config = dapui.open
                    dap.listeners.before.event_terminated.dapui_config = dapui.close
                    dap.listeners.before.event_exited.dapui_config = dapui.close

                    vim.keymap.set(
                      "v", "<leader>da", dapui.eval,
                      {desc = "DAP UI evaluate the currently highlighted expression"}
                    )
                  end,
                })
              '';
            }

            {
              plugin = nvim-dap-virtual-text;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "nvim-dap-virtual-text",
                  event = "BufWinEnter",
                  before = function()
                    require("lz.n").trigger_load("nvim-dap")
                  end,
                  after = function()
                    require("nvim-dap-virtual-text").setup({
                      commented = true,
                    })
                  end,
                })
              '';
            }
          ]
          ++ optionals (cppEnabled || rustEnabled) [
            {
              plugin = nvim-dap-rr;
              optional = true;
              type = "lua";
              config = ''
                require("lz.n").load({
                  "nvim-dap-rr",
                  ft = {"c", "cpp", "rust"},
                  before = function()
                    require("lz.n").trigger_load("nvim-dap")
                  end,
                  after = function()
                    local dap, dap_rr = require("dap"), require("nvim-dap-rr")

                    dap_rr.setup({
                      mappings = {
                        -- change these defaults to match
                        -- your usual debugger mappings
                        continue = "<leader>dc",
                        step_over = "<leader>dv",
                        step_out = "<leader>do",
                        step_into = "<leader>di",
                        reverse_continue = "<leader>dC",
                        reverse_step_over = "<leader>dV",
                        reverse_step_out = "<leader>dO",
                        reverse_step_into = "<leader>dI",

                        -- instruction level stepping
                        step_over_i = "<leader>de",
                        step_out_i = "<leader>dm",
                        step_into_i = "<leader>dn",
                        reverse_step_over_i = "<leader>dE",
                        reverse_step_out_i = "<leader>dM",
                        reverse_step_into_i = "<leader>dN",
                      },
                    })

                    table.insert(dap.configurations.c, dap_rr.get_config())
                    table.insert(dap.configurations.cpp, dap_rr.get_config())
                    table.insert(dap.configurations.rust, dap_rr.get_rust_config())
                  end,
                })
              '';
            }
          ]
          ++ optionals goEnabled [
            {
              plugin = nvim-dap-go;
              optional = true;
              type = "lua";
              config = let
                ft = ''"go", "godoc", "gomod"'';
              in ''
                require("lz.n").load({
                  "nvim-dap-go",
                  ft = { ${ft} },
                  before = function()
                    require("lz.n").trigger_load("nvim-dap")
                  end,
                  after = function()
                    local dap_go = require("dap-go")

                    dap_go.setup({
                      dap_configurations = {
                        {
                          type = "go",
                          name = "Debug (Build Flags)",
                          request = "launch",
                          program = "''${file}",
                          buildFlags = dap_go.get_build_flags,
                        },
                        {
                          type = "go",
                          name = "Debug (Build Flags & Arguments)",
                          request = "launch",
                          program = "''${file}",
                          args = dap_go.get_arguments,
                          buildFlags = dap_go.get_build_flags,
                        },
                        {
                          type = "go",
                          name = "Attach remote",
                          mode = "remote",
                          request = "attach",
                        },
                      },
                    })

                    vim.api.nvim_create_autocmd("FileType", {
                      group = ${dapAugroup},
                      desc = "Create custom debugger keymaps for go filetypes",
                      pattern = { ${ft} },
                      callback = function()
                        vim.schedule(function()
                          local bufnr = vim.api.nvim_get_current_buf()

                          vim.keymap.set("n", "<leader>dt", dap_go.debug_test, {
                            buffer = bufnr,
                            silent = true,
                            desc = "DAP Go debug the closest method above the cursor",
                          })

                          vim.keymap.set("n", "<leader>dl", dap_go.debug_last_test, {
                            buffer = bufnr,
                            silent = true,
                            desc = "DAP Go run the last run test from anywhere",
                          })
                        end)
                      end,
                    })
                  end,
                })
              '';
            }
          ]
          ++ optionals luaEnabled [
            {
              plugin = one-small-step-for-vimkind;
              optional = true;
              type = "lua";
              config = let
                ft = ''"lua"'';
              in ''
                require("lz.n").load({
                  "one-small-step-for-vimkind",
                  ft = ${ft},
                  before = function()
                    require("lz.n").trigger_load("nvim-dap")
                  end,
                  after = function()
                    vim.api.nvim_create_autocmd("FileType", {
                      group = ${dapAugroup},
                      desc = "Create custom debugger keymaps for python filetypes",
                      pattern = { ${ft} },
                      callback = function()
                        vim.schedule(function()
                          vim.keymap.set("n", "<leader>dl", function()
                            require("osv").launch({port = 8086})
                          end, {
                            buffer = vim.api.nvim_get_current_buf(),
                            silent = true,
                            desc = "Osv launch lua debugger using neovim",
                          })
                        end)
                      end,
                    })
                  end,
                })
              '';
            }
          ]
          ++ optionals pyEnabled [
            {
              plugin = nvim-dap-python;
              type = "lua";
              optional = true;
              config = let
                ft = ''"python"'';
              in ''
                require("lz.n").load({
                  "nvim-dap-python",
                  ft = ${ft},
                  before = function()
                    require("lz.n").trigger_load("nvim-dap")
                  end,
                  after = function()
                    local dap_py = require("dap-python")

                    dap_py.setup("python3")

                    vim.api.nvim_create_autocmd("FileType", {
                      group = ${dapAugroup},
                      desc = "Create custom debugger keymaps for python filetypes",
                      pattern = { ${ft} },
                      callback = function()
                        vim.schedule(function()
                          local bufnr = vim.api.nvim_get_current_buf()

                          vim.keymap.set("n", "<leader>dn", dap_py.test_method, {
                            buffer = bufnr,
                            silent = true,
                            desc = "DAP Python test method",
                          })
                          vim.keymap.set("n", "<leader>df", dap_py.test_class, {
                            buffer = bufnr,
                            silent = true,
                            desc = "DAP Python test class",
                          })
                          vim.keymap.set("v", "<leader>ds", dap_py.debug_selection, {
                            buffer = bufnr,
                            silent = true,
                            desc = "DAP Python debug selection",
                          })
                        end)
                      end,
                    })
                  end,
                })
              '';
            }
          ];
    };
  }
