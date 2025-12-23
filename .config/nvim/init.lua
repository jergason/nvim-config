-- Entrypoint for my Neovim configuration!
-- We bootstrap lazy.nvim and nfnl independently.
-- nfnl compiles fennel files on save, we require the compiled lua.

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

-- Bootstrap nfnl (compiles fennel on save)
local nfnl_path = fn.stdpath("data") .. "/nfnl"
if fn.empty(fn.glob(nfnl_path)) > 0 then
  execute(string.format("!git clone https://github.com/Olical/nfnl %s", nfnl_path))
end
vim.opt.rtp:prepend(nfnl_path)

-- Add fnl directory to lua path so require('config.init') finds fnl/config/init.lua
local config_path = fn.stdpath("config")
package.path = config_path .. "/fnl/?.lua;" .. config_path .. "/fnl/?/init.lua;" .. package.path

-- generate helptags for stuff that we don't install directly w/ lazy
execute("helptags ALL")

-- Load config (nfnl compiles .fnl -> .lua, we require the lua)
require('config.init')
