{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.programs.neovim.filetype = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Whether or not to enable filetype-related plugins.";

    editorconfig.enable =
      mkEnableOption
      "Whether or not to enable editorconfig.nvim.";

    glow.enable = mkEnableOption "Whether or not to enable glow.nvim.";

    neorg.enable = mkEnableOption "Whether or not to enable neorg.";
  };

  config = let
    cfg = config.tgap.programs.neovim.filetype;
    inherit (lib) mkIf optionals;
  in
    mkIf cfg.enable {
      tgap.programs.glow.enable = cfg.glow.enable;

      tgap.programs.neovim.startPackages =
        optionals cfg.editorconfig.enable [pkgs.vimPlugins.editorconfig-nvim];

      tgap.programs.neovim.optPackages =
        (
          optionals cfg.glow.enable [pkgs.vimPlugins.glow-nvim]
        )
        ++ (
          optionals cfg.neorg.enable [pkgs.vimPlugins.plenary-nvim pkgs.vimPlugs.neorg]
        );

      tgap.programs.neovim.luaExtraConfig = let
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
