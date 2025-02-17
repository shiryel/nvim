-- helpers
local function nnoremap(bind, command, desc)
  return vim.keymap.set("n", bind, command, { noremap = true, silent = true, desc = desc })
end

-- aerial
require("aerial").setup({
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "[[", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "]]", "<cmd>AerialNext<CR>", { buffer = bufnr })
    vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>", { noremap = true, buffer = bufnr, desc = "toggle aerial" })
  end,
})

-- mini-nvim
require('mini.statusline').setup({})
-- https://github.com/rebelot/kanagawa.nvim?tab=readme-ov-file#color-palette
vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#363646" })

require('mini.indentscope').setup({
  draw = {
    animation = function(_, _) return 10 end -- ms between each step
  }
})

-- harpoon2
require("harpoon"):setup()

local harpoon = require("harpoon")
nnoremap("<C-a>", function() harpoon:list():add() end, "add to list")
nnoremap("<C-s>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, "toggle list")
nnoremap("<C-1>", function() harpoon:list():select(1) end, "select 1 from list")
nnoremap("<C-2>", function() harpoon:list():select(2) end, "select 2 from list")
nnoremap("<C-3>", function() harpoon:list():select(3) end, "select 3 from list")
nnoremap("<C-4>", function() harpoon:list():select(4) end, "select 4 from list")
nnoremap("<C-q>", function() harpoon:list():prev() end, "toggle to previous buffer on list")
nnoremap("<C-d>", function() harpoon:list():next() end, "toggle to next buffer on list")

-- luasnip
-- see: https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#loaders
-- Using an empty {} will use runtimepath, check it with: :lua =vim.opt.runtimepath._value
-- Check logs with: :lua require("luasnip").log.open()
require("luasnip.loaders.from_vscode").lazy_load({ paths = { "/etc/nvim/snippets" } })
--require("luasnip").config.setup({
--  enable_autosnippets = true
--})

-- gitsigns
require("gitsigns").setup({
  numhl = true,
  signcolumn = false,
  current_line_blame = true,
  attach_to_untracked = true,
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- use default
  -- use_internal_diff = true,
  max_file_length = 40000,
  preview_config = {
    -- Options passed to nvim_open_win
    border = "single",
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1
  }
})

-- which-key
require("which-key").setup({
  plugins = {
    marks = true,
    registers = true,
    spelling = {
      enabled = true,
      suggestions = 20
    }
  },
  ignore_missings = false
})

-- ccc-nvim
require("ccc").setup({
  highlighter = {
    auto_enable = true
  }
})

nnoremap("<leader>c", ":CccPick<CR>", "pick color")

--- focus-nvim
require("focus").setup()
