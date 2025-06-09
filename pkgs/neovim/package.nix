{
  lib,
  wrapNeovimUnstable,
  neovim-unwrapped,
  bashInteractive,
  bashdb,
  delve,
  glow,
  harper,
  haskellPackages,
  hunspellDicts,
  hyprls,
  lldb,
  runCommand,
  tree-sitter,
  vimPlugins,
  wordnet,
  withAutocomp ? true,
  withMotion ? true,
  withHarpoon ? true,
  withLeap ? true,
  withStatusline ? true,
  withTabline ? true,
  withEditorconfig ? true,
  withGlow ? true,
  withNeorg ? true,
  withTreesitter ? true,
  withDap ? true,
  withLsp ? true,
  withUfo ? true,
  colorscheme ? "rose-pine",
  extraLspLanguages ? [
    "cpp"
    "go"
    "haskell"
    "hypr"
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
  ],
}: let
  inherit (builtins) readFile;
  inherit (lib) optionals;
in
  wrapNeovimUnstable neovim-unwrapped {
    autoconfigure = true;
    autowrapRuntimeDeps = true;
    luaRcContent = readFile ./init.lua;
    # plugins accepts a list of either plugins or { plugin = ...; config = ..vimscript.. };
    plugins = with vimPlugins;
      [
        plenary-nvim
      ]
      ++ optionals withAutocomp [
      ]
      ++ optionals (colorscheme == "rose-pine") [
        {
          plugin = rose-pine;
          type = "lua";
          config = ''
            lua << EOF
              require("rose-pine").setup({
                dark_variant = "moon",
                dim_inactive_windows = true,
              })

              vim.cmd("colorscheme rose-pine")
            EOF
          '';
        }
      ]
      ++ optionals (colorscheme == "tokyonight") [
        {
          plugin = tokyonight-nvim;
          config = "lua vim.cmd('colorscheme tokyonight')";
        }
      ];
  }
