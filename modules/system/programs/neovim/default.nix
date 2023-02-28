{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./lsp
    ./completion.nix
    ./filetype.nix
    ./fuzzy.nix
    ./git.nix
    ./motion.nix
    ./snippets.nix
    ./statusline.nix
    ./treesitter.nix
    ./ui.nix
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
        python310.withPackages
        (pyps: [
          pyps.black
          pyps.mypy
          pyps.pylint
          pyps.pynvim
        ])
      ];
    };
}
