{pkgs, ...}: {
  home.file.init-lua = {
    source = ../../../../modules/system/programs/neovim/lua/init.lua;
    target = ".config/nvim/init.lua";
  };
}
