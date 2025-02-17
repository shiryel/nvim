local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

local function nnoremap(bind, command, desc)
  return vim.keymap.set("n", bind, command, { noremap = true, silent = true, desc = desc })
end

--require('telescope').setup{
--  defaults = {
--    mappings = {
--      i = {
--        ["<C-up>"] = "preview_scrolling_up",
--        ["<C-down>"] = "preview_scrolling_down",
--        ["<C-left>"] = "preview_scrolling_left",
--        ["<C-right>"] = "preview_scrolling_right",
--        -- map actions.which_key to <C-h> (default: <C-/>)
--        -- actions.which_key shows the mappings for your picker,
--        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
--        ["<C-h>"] = "which_key"
--      }
--    }
--  }
--}

-- Fzf-lua --
local fzf = require('fzf-lua')
nnoremap("<Leader>sb", fzf.buffers, "open buffers")
nnoremap("<Leader>sf", fzf.files, "find or fd on a path")
nnoremap("<Leader>sF", fzf.oldfiles, "opened files history")
nnoremap("<Leader>st", fzf.tabs, "open tabs")
nnoremap("<Leader>sT", fzf.tags, "search project tags")
nnoremap("<Leader>sa", fzf.grep_project, "search all project lines")
nnoremap("<Leader>ss", fzf.live_grep_glob, "live grep current project")
nnoremap("<Leader>sS", fzf.live_grep_resume, "live grep continue last search")
nnoremap("<Leader>sh", fzf.search_history, "search history")
nnoremap("<Leader>sq", fzf.quickfix, "quickfix list")
nnoremap("<Leader>sQ", fzf.quickfix_stack, "quickfix stack")
nnoremap("<Leader>sl", fzf.loclist, "location list")
nnoremap("<Leader>sL", fzf.loclist_stack, "location stack")
nnoremap("<Leader>so", fzf.jumps, "jumps")
nnoremap("<Leader>sr", fzf.registers, "registers")
nnoremap("<Leader>sk", fzf.keymaps, "keymaps")
nnoremap("<Leader>sc", fzf.changes, "changes")
nnoremap("<Leader>s:", fzf.command_history, "commands history")
nnoremap("<Leader>s/", fzf.search_history, "search history")
nnoremap("<Leader>s'", fzf.marks, "marks")
-- git
-- commits: checkout <cr> | reset mixed <C-r>m | reset soft <C-r>s | reset hard <C-r>h
nnoremap("<Leader>gc", fzf.git_commits, "git commit log (project)")
-- buffer commits: checkout <cr>
nnoremap("<Leader>gb", fzf.git_bcommits, "git commit log (buffer)")
-- branches: checkout <cr> | track <C-t> | rebase <C-r> | create <C-a> | switch <C-s> | delete <C-d> | merge <C-y>
nnoremap("<Leader>gt", fzf.git_branches, "git branches")
nnoremap("<Leader>gs", fzf.git_status, "git status")
nnoremap("<Leader>gS", fzf.git_stash, "git stash")

-- FZF does not work with live_grep
-- :Telescope fzf is a bug
-- Needs to be called right after telesctope to get fzf loaded
--require('telescope').load_extension('fzf')

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

-- nvim-tree
require("nvim-tree").setup({
  on_attach = function(bufnr)
    -- use :NvimTreeGenerateOnAttach to generate this function
    local function noremap(bind, command, desc)
      return vim.keymap.set("n", bind, command,
        { buffer = bufnr, noremap = true, silent = true, nowait = true, desc = 'nvim-tree: ' .. desc })
    end
    local n_api = require('nvim-tree.api')
    n_api.config.mappings.default_on_attach(bufnr) -- default mapping

    noremap('<C-up>', n_api.tree.change_root_to_parent, "Dir up")
    noremap('s', n_api.node.open.vertical, "Open: Vertical Split")
    noremap('v', n_api.node.open.horizontal, "Open: Horizontal Split")
    noremap('?', n_api.tree.toggle_help, "Help")
    noremap('P',
      function()
        local node = n_api.tree.get_node_under_cursor()
        print(node.absolute_path)
      end, "Print Node Path")
  end,
  disable_netrw = true,
  hijack_netrw = false,
  sort_by = "case_sensitive",
  sync_root_with_cwd = true, -- may change root when dir change
  respect_buf_cwd = true,    -- change to cwd when opening
  update_focused_file = {
    enable = false,
    update_root = false
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = ""
    }
  },
  modified = {
    enable = true
  },
  view = {
    width = 36,
  },
  renderer = {
    root_folder_label = false,
    add_trailing = true
  },
  filters = {
    dotfiles = false
  },
  actions = {
    open_file = {
      quit_on_open = false
    }
  },
  tab = {
    sync = {
      open = true,
      close = true
    }
  }
})

nnoremap("<leader>e", ":NvimTreeFindFile<cr>", "open file tree")
nnoremap("<leader>E", ":NvimTreeToggle<cr>", "toggle file tree")
