{
  config,
  lib,
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

  options.tgap.home.programs.neovim = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    enable = mkEnableOption "neovim";
    alias = mkEnableOption "vi and vim aliases";

    runtimepath = mkOption {
      type = types.str;
      default = "${config.xdg.configHome}/nvim";
      description = "The main runtimepath housing most neovim configs.";
    };
  };

  config = let
    cfg = config.tgap.home.programs.neovim;
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      home.file = {
        "${cfg.runtimepath}/ftplugin/javascript.lua".text = "vim.bo.tabstop = 2";
        "${cfg.runtimepath}/ftplugin/javascriptreact.lua".text = "vim.bo.tabstop = 2";
        "${cfg.runtimepath}/ftplugin/json.lua".text = "vim.bo.tabstop = 2";
        "${cfg.runtimepath}/ftplugin/jsonc.lua".text = "vim.bo.tabstop = 2";
        "${cfg.runtimepath}/ftplugin/lua.lua".text = "vim.bo.tabstop = 2";
        "${cfg.runtimepath}/ftplugin/nix.lua".text = "vim.bo.tabstop = 2";
        "${cfg.runtimepath}/ftplugin/typescript.lua".text = "vim.bo.tabstop = 2";
        "${cfg.runtimepath}/ftplugin/typescriptreact.lua".text = "vim.bo.tabstop = 2";
        "${cfg.runtimepath}/ftplugin/yuck.lua".text = "vim.bo.tabstop = 2";
      };

      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = cfg.alias;
        vimAlias = cfg.alias;
        vimdiffAlias = cfg.alias;
        withPython3 = true;
        withNodeJs = true;

        extraLuaConfig = ''
          -- Base Configuration
          ${builtins.readFile ./lua/init.lua}
        '';
      };
    };
}
