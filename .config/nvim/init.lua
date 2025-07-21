-- Entrypoint for my Neovim configuration!
-- We bootstrap lazy.nvim and aniseed independently.
-- It's then up to Aniseed to compile and load fnl/config/init.fnl

local execute = vim.api.nvim_command
local fn = vim.fn

-- Bootstrap lazy.nvim
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Bootstrap aniseed (to its own directory)
local aniseed_path = fn.stdpath("data") .. "/aniseed"
if fn.empty(fn.glob(aniseed_path)) > 0 then
  execute(string.format("!git clone --branch develop https://github.com/Olical/aniseed %s", aniseed_path))
end
vim.opt.rtp:prepend(aniseed_path)

-- generate helptags for stuff that we don't install directly w/ lazy
execute("helptags ALL")

require('aniseed.env').init({module = "config.init", compile = true})
