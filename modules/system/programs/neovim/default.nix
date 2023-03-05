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

  options.tgap.programs.neovim = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "Whether or not to enable neovim.";

    aliases = mkEnableOption "Whether or not to enable vi and vim aliases.";

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
    cfg = config.tgap.programs.neovim;
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = cfg.aliases;
        vimAlias = cfg.aliases;

        runtime = {
          "init.lua".source = ./init.lua;
          "lua/extraConfig.lua".text = cfg.luaExtraConfig;
        };
      };

      environment.systemPackages = [
        (pkgs.python310.withPackages (ps: [ps.pynvim]))
      ];
    };
}
