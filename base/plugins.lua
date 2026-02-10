local fn = vim.fn

local function nnoremap(bind, command, desc)
  return vim.keymap.set("n", bind, command, { noremap = true, silent = true, desc = desc })
end

-- Fzf-lua --
local fzf = require('fzf-lua')
fzf.setup({
  color_icons = true,
  file_icons = true,
})
nnoremap("<leader>b", fzf.buffers, "open buffers")
nnoremap("<leader>f", fzf.files, "find or fd on a path")
nnoremap("<leader>F", fzf.oldfiles, "opened files history")
nnoremap("<leader>t", fzf.tabs, "open tabs")
--nnoremap("<leader>st", fzf.tags, "search project tags")
nnoremap("<leader>a", fzf.grep_project, "search all project lines with Rg")
nnoremap("<leader>A", fzf.search_history, "search history")
nnoremap("<leader>s", fzf.live_grep, "live grep current project")
nnoremap("<leader>S", fzf.live_grep_resume, "live grep continue last search")
nnoremap("<leader>q", fzf.quickfix, "quickfix list")
nnoremap("<leader>Q", fzf.quickfix_stack, "quickfix stack")
nnoremap("<leader>l", fzf.loclist, "location list")
nnoremap("<leader>L", fzf.loclist_stack, "location stack")
nnoremap("<leader>o", fzf.jumps, "jumps")
nnoremap("<leader>\"", fzf.registers, "registers")
nnoremap("<leader>k", fzf.keymaps, "keymaps")
nnoremap("<leader>c", fzf.changes, "changes")
nnoremap("<leader>:", fzf.command_history, "commands history")
nnoremap("<leader>/", fzf.search_history, "search history")
nnoremap("<leader>'", fzf.marks, "marks")
-- git
-- commits: checkout <cr> | reset mixed <C-r>m | reset soft <C-r>s | reset hard <C-r>h
nnoremap("<leader>gc", fzf.git_commits, "git commit log (project)")
-- buffer commits: checkout <cr>
nnoremap("<leader>gb", fzf.git_bcommits, "git commit log (buffer)")
-- branches: checkout <cr> | track <C-t> | rebase <C-r> | create <C-a> | switch <C-s> | delete <C-d> | merge <C-y>
nnoremap("<leader>gt", fzf.git_branches, "git branches")
nnoremap("<leader>gs", fzf.git_status, "git status")
nnoremap("<leader>gS", fzf.git_stash, "git stash")

-- nvim-treesitter
local _, treesitter_pattern = xpcall(require('nvim-treesitter').get_available, function() return '*' end)
vim.api.nvim_create_autocmd('FileType', {
  pattern = treesitter_pattern,
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local path = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))

    -- highlighting

    -- some files are too big for treesitter to work...
    -- ignore if > 3mb (size in bytes)
    if (vim.fn.getfsize(path) < 3 * 1024 * 1024) then
      pcall(vim.treesitter.start)

      -- indentation
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

      -- folds
      vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo[0][0].foldmethod = 'expr'
    end
  end
})

require("shade").setup()

require("lightbulb").setup()

-- ranger
local ranger = require("ranger")
ranger.setup({
  enable_cmds = false,
  replace_netrw = true,
  keybinds = {
    ["ov"] = ranger.OPEN_MODE.vsplit,
    ["oh"] = ranger.OPEN_MODE.split,
    ["ot"] = ranger.OPEN_MODE.tabedit,
    ["or"] = ranger.OPEN_MODE.rifle,
  },
  ui = {
    border = "rounded",
    height = 0.9,
    width = 0.9,
  }
})
nnoremap("<leader>e", function() ranger.open(true) end, "ranger: open")
