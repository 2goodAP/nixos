{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./lsp
    ./autocompletion.nix
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
    enable = mkEnableOption "Whether or not to enable neovim.";

    alias = mkEnableOption "Whether or not to enable vi and vim aliases.";

    luaExtraConfig = mkOption {
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
            luafile ${./init.lua}

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
      };

      environment.systemPackages = [
        (pkgs.python310.withPackages (ps: [ps.pynvim]))
      ];
    };
}
