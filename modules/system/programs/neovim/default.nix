{
  config,
  lib,
  options,
  pkgs,
  ...
}: {
  imports = [
    ./langtools
    ./autocompletion.nix
    ./colorscheme.nix
    ./filetype.nix
    ./git.nix
    ./motion.nix
    ./statusline.nix
    ./telescope.nix
    ./treesitter.nix
    ./ui.nix
  ];

  options.tgap.system.programs.neovim = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "Whether or not to install neovim.";
    alias = mkEnableOption "Whether or not to enable vi and vim aliases.";

    luaExtraConfigEarly = mkOption {
      type = types.lines;
      default = "";
      description = "The lua configuration to source into neovim before all other configuration.";
    };

    luaExtraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "The lua configuration to source into neovim.";
    };

    startPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "The packages to load into neovim during startup.";
    };

    optPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "The packages to load optionally into neovim.";
    };

    python = {
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "The python package to use to install into the environment";
      };

      extraPackageNames = mkOption {
        type = types.listOf types.str;
        default = ["pynvim"];
        description = "The packages to install alongside python.";
      };
    };
  };

  config = let
    cfg = config.tgap.system.programs.neovim;
    opts = options.tgap.system.programs.neovim;
    python = pkgs.python311.withPackages (
      ps: lib.forEach cfg.python.extraPackageNames (name: ps."${name}")
    );
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      environment.systemPackages = [python];

      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = cfg.alias;
        vimAlias = cfg.alias;
        withPython3 = true;
        withNodeJs = true;

        configure = {
          customRC = ''
            luafile ${./lua/init.lua}

            " Add plugin specific extra lua configuration.
            lua << EOF
              -- Early Configuration
              ${cfg.luaExtraConfigEarly}

              -- Main Configuration
              ${cfg.luaExtraConfig}
            EOF
          '';

          packages.nixPlugins = {
            start = cfg.startPackages;
            opt = cfg.optPackages;
          };
        };

        runtime = {
          "ftplugin/javascript.lua".text = "vim.bo.tabstop = 2";
          "ftplugin/lua.lua".text = "vim.bo.tabstop = 2";
          "ftplugin/nix.lua".text = "vim.bo.tabstop = 2";
          "ftplugin/yuck.lua".text = "vim.bo.tabstop = 2";
        };
      };

      tgap.system.programs.neovim.python = {
        package = python;
        extraPackageNames = opts.python.extraPackageNames.default;
      };
    };
}
