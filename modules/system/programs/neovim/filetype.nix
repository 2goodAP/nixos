{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.machine.programs.neovim.filetype;
  inherit (lib) mkIf mkEnableOption optionals;
in {
  options.machine.programs.neovim.filetype = {
    enable = mkEnableOption "Whether or not to enable filetype-related plugins.";

    editorconfig.enable =
      mkEnableOpton
      "Whether or not to enable editorconfig.nvim.";

    glow.enable = mkEnableOpton "Whether or not to enable glow.nvim.";

    neorg.enable = mkEnableOpton "Whether or not to enable neorg.";
  };

  config = mkIf cfg.enable {
    machine.programs.glow.enable = cfg.glow.enable;

    machine.programs.neovim.startPackages =
      optionals cfg.editorconfig.enable [pkgs.vimPlugins.editorconfig-nvim];

    machine.programs.neovim.optPackages =
      (
        optionals cfg.glow.enable [pkgs.vimPlugins.glow-nvim]
      )
      ++ (
        optionals cfg.neorg.enable [pkgs.vimPlugins.plenary-nvim pkgs.vimPlugs.neorg]
      );

    machine.programs.neovim.luaConfig = let
      writeIf = cond: msg:
        if cond
        then msg
        else "";
    in ''
      ${writeIf cfg.glow.enable ''
        vim.api.nvim_create_augroup('MarkdownGroup')
        vim.api.nvim_clear_autocmd({group = 'MarkdownGroup'})
        vim.api.nvim_create_autocmd(
          {'BufEnter', 'BufWinEnter'},
          {
            pattern = {'*.md'},
            command = function() require('glow').setup() end,
            group = "MarkdownGroup"
          }
        )
      ''}

      ${writeIf cfg.neorg.enable ''
        vim.api.nvim_create_augroup('NeorgGroup')
        vim.api.nvim_clear_autocmd({group = 'NeorgGroup'})
        vim.api.nvim_create_autocmd(
          {'BufEnter', 'BufWinEnter'},
          {
            pattern = {'*.norg'},
            command = function() require('neorg').setup() end,
            group = "NeorgGroup"
          }
        )
      ''}
    '';
  };
}
