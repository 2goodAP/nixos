{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./cpp.nix
    ./haskell.nix
    ./lua.nix
    ./nix.nix
    ./python.nix
    ./rust.nix
    ./typescript.nix
  ];

  options.tgap.system.programs.neovim.langtools = let
    inherit (lib) mkIf mkEnableOption mkOption optionals types;
  in {
    languages = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        The extra language servers to be installed. Supported languages are
        "cpp", "haskell", "lua", "nix", "python", "rust", "typescript".
      '';
    };

    dap.enable = mkEnableOption "Whether or not to enable dap-related plugins.";

    lsp = {
      enable = mkEnableOption "Whether or not to enable lsp-related plugins.";

      lspsaga.enable = mkEnableOption "Whether or not to enable lspsaga.nvim.";

      lspSignature.enable =
        mkEnableOption "Whether or not to enable lsp-signature.nvim.";

      ufo.enable = mkEnableOption "Whether or not to enable ufo.nvim.";
    };
  };

  config = let
    cfg = config.tgap.system.programs.neovim;
    inherit (lib) mkIf mkMerge optionals optionalString;
  in
    mkMerge [
      (mkIf cfg.langtools.dap.enable {
        tgap.system.programs.neovim.startPackages = [pkgs.vimPlugins.nvim-dap];
      })

      (mkIf cfg.langtools.lsp.enable {
        tgap.system.programs.neovim.startPackages =
          [pkgs.vimPlugins.nvim-lspconfig pkgs.vimPlugins.null-ls-nvim]
          ++ (
            optionals cfg.langtools.lsp.lspsaga.enable [pkgs.vimPlugins.lspsaga-nvim]
          )
          ++ (
            optionals cfg.langtools.lsp.lspSignature.enable [pkgs.vimPlugins.lsp_signature-nvim]
          )
          ++ (
            optionals cfg.langtools.lsp.ufo.enable [pkgs.vimPlugins.nvim-ufo]
          );

        tgap.system.programs.neovim.luaExtraConfig = ''
          -- Mappings.
          -- See `:help vim.diagnostic.*` for documentation on
          -- any of the below functions.
          local opts = {noremap=true, silent=true}
          vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

          ${optionalString cfg.langtools.lsp.lspsaga.enable ''
            require("lspsaga").setup({})
          ''}

          ${optionalString cfg.langtools.lsp.lspSignature.enable ''
            require "lsp_signature".setup({
              bind = true, -- This is mandatory.
              handler_opts = {
                border = "rounded"
              }
            })
          ''}

          ${optionalString cfg.langtools.lsp.ufo.enable ''
            vim.o.foldcolumn = "1" -- "0" is not bad
            vim.o.foldlevel = 99 -- Using ufo provider need a large value
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            -- Using ufo provider need remap `zR` and `zM`.
            vim.keymap.set("n", "zR", require("ufo").openAllFolds)
            vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

            -- Using nvim lsp as LSP client
            -- Tell the server the capability of foldingRange,
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true
            }
            local servers = require("lspconfig").util.available_servers()
            for _, ls in ipairs(servers) do
                require("lspconfig")[ls].setup({
                    capabilities = capabilities
                })
            end
            require("ufo").setup()
          ''}
        '';
      })
    ];
}
