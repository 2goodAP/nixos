{pkgs, ...}: {
  xdg.configFile.init-lua = {
    source = ../../../../modules/system/programs/neovim/lua/init.lua;
    target = "nvim/init.lua";
  };
}
