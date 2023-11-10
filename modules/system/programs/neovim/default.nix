{
  config,
  lib,
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
  };

  config = let
    cfg = config.tgap.system.programs.neovim;
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
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

      environment.systemPackages = [
        (pkgs.python310.withPackages (ps: [ps.pynvim]))
      ];
    };
}
