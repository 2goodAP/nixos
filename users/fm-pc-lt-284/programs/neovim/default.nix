{pkgs, ...}: {
  home.file.init-lua = {
    source = ../../../../modules/system/programs/neovim/init.lua;
    target = ".config/nvim/init.lua";
  };
}
