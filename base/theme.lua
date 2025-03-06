-- BASED ON: 
-- https://github.com/Rydwxz/bhs/blob/main/lua/black_hole_sun/theme.lua
-- https://github.com/rebelot/kanagawa.nvim

local hl = vim.api.nvim_set_hl

if vim.g.colors_name then
  vim.cmd("hi clear")
end
vim.g.colors_name = "kanagawa-shiny"
vim.o.termguicolors = true
