local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

local function nnoremap(bind, command, desc)
  return vim.keymap.set("n", bind, command, { noremap = true, silent = true, desc = desc })
end

--local telescope = require('telescope')
--local telescope_actions = require "telescope.actions"
--telescope.setup {
--  defaults = {
--    -- see: https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/mappings.lua
--    mappings = {
--      i = {
--        ["<c-up>"] = telescope_actions.preview_scrolling_up,
--        ["<c-down>"] = telescope_actions.preview_scrolling_down,
--        -- c-left/right is used on the input
--        ["<c-s-left>"] = telescope_actions.preview_scrolling_left,
--        ["<c-s-right>"] = telescope_actions.preview_scrolling_right,
--        -- https://github.com/nvim-telescope/telescope.nvim/issues/564
--        ["<c-s>"] = telescope_actions.to_fuzzy_refine,
--        -- map actions.which_key to <C-h> (default: <C-/>)
--        -- actions.which_key shows the mappings for your picker,
--        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
--        ["<c-h>"] = telescope_actions.which_key
--      }
--    }
--  },
--  extensions = {
--    file_browser = {
--      theme = "ivy",
--      -- disables netrw and use telescope-file-browser in its place
--      hijack_netrw = true,
--      mappings = {
--        ["i"] = {
--          -- your custom insert mode mappings
--        },
--        ["n"] = {
--          -- your custom normal mode mappings
--        },
--      },
--    },
--  },
--}
--
---- FZF does not work with live_grep
---- :Telescope fzf is a bug
---- Needs to be called right after telesctope to get fzf loaded
--telescope.load_extension('fzf')
--
--local telescope_b = require('telescope.builtin')
--nnoremap("<leader>b", telescope_b.buffers, "open buffers")
--nnoremap("<leader>f", telescope_b.find_files, "find or fd on a path")
--nnoremap("<leader>F", telescope_b.oldfiles, "opened files history")
----nnoremap("<leader>t", telescope_b.tabs, "open tabs")
--nnoremap("<leader>t", telescope_b.tags, "search project tags")
--nnoremap("<leader>s", telescope_b.live_grep, "search using rg, <c-s> to refine with fzf, respects .gitignore")
--nnoremap("<leader>a",
--  function() telescope_b.grep_string({ shorten_path = true, word_match = "-w" }) end,
--  "search on current working directory")
--nnoremap("<leader>A",
--  function() telescope_b.grep_string({ shorten_path = true, word_match = "-w", only_sort_text = true }) end,
--  "search on current working directory")
--nnoremap("<leader>S", telescope_b.search_history, "search history")
--nnoremap("<leader>q", telescope_b.quickfix, "quickfix list")
--nnoremap("<leader>Q", telescope_b.quickfixhistory, "quickfix history")
--nnoremap("<leader>l", telescope_b.loclist, "location list")
--nnoremap("<leader>o", telescope_b.jumplist, "jumps")
--nnoremap("<leader>\"", telescope_b.registers, "registers")
--nnoremap("<leader>k", telescope_b.keymaps, "keymaps")
--nnoremap("<leader>:", telescope_b.command_history, "commands history")
--nnoremap("<leader>/", telescope_b.search_history, "search history")
--nnoremap("<leader>'", telescope_b.marks, "marks")
---- git
---- commits: checkout <cr> | reset mixed <C-r>m | reset soft <C-r>s | reset hard <C-r>h
--nnoremap("<leader>c", telescope_b.git_status, "git changes")
--nnoremap("<leader>gc", telescope_b.git_commits, "git commit log (project)")
---- buffer commits: checkout <cr>
--nnoremap("<leader>gb", telescope_b.git_bcommits, "git commit log (buffer)")
---- branches: checkout <cr> | track <C-t> | rebase <C-r> | create <C-a> | switch <C-s> | delete <C-d> | merge <C-y>
--nnoremap("<leader>gt", telescope_b.git_branches, "git branches")
--nnoremap("<leader>gs", telescope_b.git_status, "git status")
--nnoremap("<leader>gS", telescope_b.git_stash, "git stash")
--
---- Telescope File Browser Extension
--telescope.load_extension("file_browser")
--nnoremap("<leader>e", ":Telescope file_browser<CR>", "open file browser")
--nnoremap("<leader>E", ":Telescope file_browser path=%:p:h select_buffer=true<CR>", "open file browser on current path")

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

require('kanagawa').setup({
  undercurl = false,
  colors = {
    theme = { all = { diag = { error = "#727169" } } }, -- fujiGray
  }
})

cmd("colorscheme kanagawa-wave")

-- nvim-treesitter
require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = { "kotlin" },
    -- some files are too big for treesitter to work...
    disable = function(lang, bufnr)
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

-- ranger
require("ranger").setup({
  width = 0.9,
  height = 0.9,
  position = 'cc',
})
nnoremap("<leader>e", ":Ranger<CR>", "ranger: open")
nnoremap("<leader>E<left>", ":Ranger left<CR>", "ranger: open left")
nnoremap("<leader>E<down>", ":Ranger down<CR>", "ranger: open down")
nnoremap("<leader>E<up>", ":Ranger up<CR>", "ranger: open up")
nnoremap("<leader>E<right>", ":Ranger right<CR>", "ranger: open right")
