{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./completion
    ./filetype
    ./fuzzy
    ./git
    ./lsp
    ./motion
    ./snippets
    ./statusline
    ./treesitter
    ./ui
  ];

  options.machine.programs.neovim = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "Whether or not to enable neovim.";

    aliases = mkEnableOption "Whether or not to enable vi and vim aliases.";

    luaConfigRC = mkOption {
      description = "The lua configuration to source into neovim.";
      type = types.lines;
      default = "";
    };

    startPackages = mkOption {
      description = "The packages to load into neovim during startup.";
      type = types.listOf types.package;
      default = [];
    };

    optPackages = mkOption {
      description = "The packages to load optionally into neovim.";
      type = types.listOf types.package;
      default = [];
    };

     = {
      completion = mkEnableOption {
        description = "Whether or not to enable completion-related plugins.";
      };

      dap = mkEnableOption {
        description = "Whether or not to enable dap-related plugins.";
      };

      filetype = {
        editorconfig = mkEnableOption {
          description = "Whether or not to enable the editorconfig plugin.";
        };
        markdown = mkEnableOption {
          description = "Whether or not to enable the markdown plugin.";
        };
        neorg = mkEnableOption {
          description = "Whether or not to enable the neorg plugin.";
        };
      };

      lsp = mkEnableOption {
        description = "Whether or not to enable lsp-related plugins.";
      };

      search = mkEnableOption {
        description = "Whether or not to enable fuzzy search-related plugins.";
      };

      snippet = mkEnableOption {
        description = "Whether or not to enable snippet-related plugins.";
      };

      statusline = mkEnableOption {
        description = "Whether or not to enable statusline-related plugins.";
      };

      treesitter = mkEnableOption {
        description = "Whether or not to enable treesitter-related plugins.";
      };

      ui = mkEnableOption {
        description = "Whether or not to enable ui-related plugins.";
      };
    };
  };

  config = let
    cfg = config.machine.programs.neovim;
  in
    mkIf cfg.enable {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = cfg.aliases;
        vimAlias = cfg.aliases;

        runtime = {
          "init.lua".source = ./init.lua;
        };
      };

      environment.systemPackages = [
        python3Minimal.withPackages
        (pyps: [
          pyps.black
          pyps.mypy
          pyps.pylint
        ])
      ];
    };
}
