{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tgap.system.programs.neovim.filetype = let
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
    cfg = config.tgap.system.programs.neovim.filetype;
    inherit (lib) mkIf optionals;
    inherit (lib.strings) optionalString;
  in
    mkIf cfg.enable {
      tgap.system.programs.glow.enable = cfg.glow.enable;

      tgap.system.programs.neovim.startPackages =
        optionals cfg.editorconfig.enable [pkgs.vimPlugins.editorconfig-nvim];

      tgap.system.programs.neovim.optPackages =
        (
          optionals cfg.glow.enable [pkgs.vimPlugins.glow-nvim]
        )
        ++ (
          optionals cfg.neorg.enable [pkgs.vimPlugins.plenary-nvim pkgs.vimPlugins.neorg]
        );

      tgap.system.programs.neovim.luaExtraConfig = ''
        ${optionalString cfg.glow.enable ''
          vim.api.nvim_create_augroup("MarkdownGroup", {clear = true})
          vim.api.nvim_create_autocmd(
            {"BufNewFile", "BufRead", "BufEnter", "BufWinEnter"},
            {
              pattern = {"*.md"},
              command = function() require("glow").setup() end,
              group = "MarkdownGroup"
            }
          )
        ''}

        ${optionalString cfg.neorg.enable ''
          vim.api.nvim_create_augroup("NeorgGroup", {clear = true})
          vim.api.nvim_create_autocmd(
            {"BufNewFile", "BufRead", "BufEnter", "BufWinEnter"},
            {
              pattern = {"*.norg"},
              command = function() require("neorg").setup() end,
              group = "NeorgGroup"
            }
          )
        ''}
      '';
    };
}
