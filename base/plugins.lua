local fn = vim.fn

local function nnoremap(bind, command, desc)
  return vim.keymap.set("n", bind, command, { noremap = true, silent = true, desc = desc })
end

-- Fzf-lua --
local fzf = require('fzf-lua')
nnoremap("<leader>b", fzf.buffers, "open buffers")
nnoremap("<leader>f", fzf.files, "find or fd on a path")
nnoremap("<leader>F", fzf.oldfiles, "opened files history")
nnoremap("<leader>t", fzf.tabs, "open tabs")
--nnoremap("<leader>st", fzf.tags, "search project tags")
nnoremap("<leader>a", fzf.grep_project, "search all project lines")
nnoremap("<leader>A", fzf.search_history, "search history")
nnoremap("<leader>s", fzf.live_grep_glob, "live grep current project")
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
require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = { "kotlin" },
    -- some files are too big for treesitter to work...
    disable = function(_, bufnr)
      -- ignore if > 1mb (size in bytes)
      return (fn.getfsize(bufnr) > 1000000) or false
    end
  },
  textobjects = {
    enable = true
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm"
    }
  },
  indent = {
    enable = true,
    disable = { "gdscript", "elixir" } -- gdscript ident dont work
  }
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
