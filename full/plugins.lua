-- helpers
local function nnoremap(bind, command, desc)
  return vim.keymap.set("n", bind, command, { noremap = true, silent = true, desc = desc })
end

require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    },
    progress = { enabled = true },
    message = { enabled = true },

    -- Disable LSP integration, let blink handle those
    -- see: https://github.com/folke/noice.nvim/issues/1172
    hover = { enabled = false },
    signature = { enabled = false },
  },
  --routes = {
  --  {
  --    filter = {
  --      event = "msg_show",
  --      kind = "",
  --      find = "written",
  --    },
  --    opts = { skip = true },
  --  },
  --},
  -- to disable messages, see: :h shortmess or :h report
  messages = {
    enabled = true,              -- enables the Noice messages UI
    view = "notify",             -- default view for messages
    view_error = "notify",       -- view for errors
    view_warn = "notify",        -- view for warnings
    view_history = "messages",   -- view for :messages
    view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
  },
  views = {
    cmdline_popup = {
      position = {
        row = "48%",
        col = "50%",
      },
      size = {
        width = 60,
        height = "auto",
      },
    },
    --popupmenu = {
    --  relative = "editor",
    --  position = {
    --    row = "52%",
    --    col = "50%",
    --  },
    --  size = {
    --    width = 60,
    --    height = 10,
    --  },
    --  border = {
    --    style = "rounded",
    --    padding = { 0, 1 },
    --  },
    --  win_options = {
    --    winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
    --  },
    --},
  },
})

-- codecompanion-nvim

require("codecompanion").setup({
  opts = {
    -- https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
    strategies = {
      chat = {
        adapter = "ollama",
      },
      inline = {
        adapter = "ollama",
      },
      agent = {
        adapter = "ollama",
      },
    },
    adapters = {
      coder = function()
        return require("codecompanion.adapters").extend("ollama", {
          schema = {
            model = {
              default = 'qwen2.5-coder:32b',
            },
            num_ctx = {
              default = 32768,
            },
          },
        })
      end,
    },
    display = {
      diff = {
        enabled = true,
        close_chat_at = 240,  -- Close an open chat buffer if the total columns of your display are less than...
        layout = 'vertical',  -- vertical|horizontal split for default provider
        opts = { 'internal', 'filler', 'closeoff', 'algorithm:patience', 'followwrap', 'linematch:120' },
        provider = 'default', -- default|mini_diff
      },
    },
  },
})

-- aerial
require("aerial").setup({
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "[[", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "aerial: next" })
    vim.keymap.set("n", "]]", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "aerial: prev" })
    vim.keymap.set("n", "<leader>A", "<cmd>AerialToggle!<CR>", { noremap = true, buffer = bufnr, desc = "toggle aerial" })
  end,
})

-- auto-session
--
-- test with debug on and `:=require('auto-session').AutoSaveSession()`
-- or
-- autocmd VimLeave * :call system("date >> ~/ts_vimleave.txt")
--
-- Does not work with bwrap's --unshare-pid, see:
-- - https://github.com/containers/bubblewrap/issues/369
-- - https://github.com/containers/bubblewrap/pull/586
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
require("auto-session").setup({
  enabled = true,                                   -- Enables/disables auto creating, saving and restoring
  root_dir = vim.fn.stdpath "data" .. "/sessions/", -- Root dir where sessions will be stored
  auto_save = true,                                 -- Enables/disables auto saving session on exit
  auto_restore = true,                              -- Enables/disables auto restoring session on start
  auto_create = true,                               -- Enables/disables auto creating new session files. Can take a function that should return true/false if a new session file should be created or not
  allowed_dirs = { "~/code/*" },                    -- Allow session restore/create in certain directories
  git_use_branch_name = true,                       -- Include git branch name in session name
  git_auto_restore_on_branch_change = true,         -- Should we auto-restore the session when the git branch changes. Requires git_use_branch_name
  lsp_stop_on_restore = true,                       -- Should language servers be stopped when restoring a session. Can also be a function that will be called if set. Not called on autorestore from startup
  purge_after_minutes = 14400,                      -- Sessions older than purge_after_minutes will be deleted asynchronously on startup, e.g. set to 14400 to delete sessions that haven't been accessed for more than 10 days, defaults to off (no purging), requires >= nvim 0.10
  --log_level = 'debug'
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

-- nvim-tree
-- require("nvim-tree").setup({
--   on_attach = function(bufnr)
--     -- use :NvimTreeGenerateOnAttach to generate this function
--     local function noremap(bind, command, desc)
--       return vim.keymap.set("n", bind, command,
--         { buffer = bufnr, noremap = true, silent = true, nowait = true, desc = 'nvim-tree: ' .. desc })
--     end
--     local n_api = require('nvim-tree.api')
--     n_api.config.mappings.default_on_attach(bufnr) -- default mapping
--
--     noremap('<C-up>', n_api.tree.change_root_to_parent, "Dir up")
--     noremap('s', n_api.node.open.vertical, "Open: Vertical Split")
--     noremap('v', n_api.node.open.horizontal, "Open: Horizontal Split")
--     noremap('?', n_api.tree.toggle_help, "Help")
--     noremap('P',
--       function()
--         local node = n_api.tree.get_node_under_cursor()
--         print(node.absolute_path)
--       end, "Print Node Path")
--   end,
--   disable_netrw = true,
--   hijack_netrw = false,
--   sort_by = "case_sensitive",
--   sync_root_with_cwd = true, -- may change root when dir change
--   respect_buf_cwd = true,    -- change to cwd when opening
--   update_focused_file = {
--     enable = false,
--     update_root = false
--   },
--   diagnostics = {
--     enable = true,
--     show_on_dirs = true,
--     icons = {
--       hint = "",
--       info = "",
--       warning = "",
--       error = ""
--     }
--   },
--   modified = {
--     enable = true
--   },
--   view = {
--     width = 36,
--   },
--   renderer = {
--     root_folder_label = false,
--     add_trailing = true
--   },
--   filters = {
--     dotfiles = false
--   },
--   actions = {
--     open_file = {
--       quit_on_open = false
--     }
--   },
--   tab = {
--     sync = {
--       open = true,
--       close = true
--     }
--   }
-- })
--
-- nnoremap("<leader>e", ":NvimTreeFindFile<cr>", "open file tree")
-- nnoremap("<leader>E", ":NvimTreeToggle<cr>", "toggle file tree")

-- spelunk
require("spelunk").setup({
  base_mappings = {
    -- Toggle the UI open/closed
    toggle = '<c-s>',
    -- Add a bookmark to the current stack
    add = '<c-a>',
    -- Move to the next bookmark in the stack
    next_bookmark = '<c-h>',
    -- Move to the previous bookmark in the stack
    prev_bookmark = '<c-t>',

    -- requires telescope:

    -- Fuzzy-find all bookmarks
    search_bookmarks = nil,
    -- Fuzzy-find bookmarks in current stack
    search_current_bookmarks = nil,
    -- Fuzzy find all stacks
    search_stacks = nil,
  },
  window_mappings = {
    -- Move the UI cursor down
    cursor_down = '<down>',
    -- Move the UI cursor up
    cursor_up = '<up>',
    -- Move the current bookmark down in the stack
    bookmark_down = '<C-down>',
    -- Move the current bookmark up in the stack
    bookmark_up = '<C-up>',
    -- Jump to the selected bookmark
    goto_bookmark = '<CR>',
    -- Jump to the selected bookmark in a new vertical split
    goto_bookmark_hsplit = 'h',
    -- Jump to the selected bookmark in a new horizontal split
    goto_bookmark_vsplit = 'v',
    -- Delete the selected bookmark
    delete_bookmark = 'd',
    -- Navigate to the next stack
    next_stack = '<Tab>',
    -- Navigate to the previous stack
    previous_stack = '<S-Tab>',
    -- Create a new stack
    new_stack = 'n',
    -- Delete the current stack
    delete_stack = 'D',
    -- Rename the current stack
    edit_stack = 'E',
    -- Close the UI
    close = 'q',
    -- Open the help menu
    help = 'h',
  },
  enable_persist = true,
  enable_status_col_display = true,
  persist_by_git_branch = true,
})

-- luasnip
-- see: https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#loaders
-- Using an empty {} will use runtimepath, check it with: :lua =vim.opt.runtimepath._value
-- Check logs with: :lua require("luasnip").log.open()
require("luasnip.loaders.from_vscode").lazy_load({ paths = { "/etc/nvim/snippets" } })
--require("luasnip").config.setup({
--  enable_autosnippets = true
--})

-- neogit
require("neogit").setup({
  integrations = {
    diffview = true,
    fzf_lua = true,
  },
})
nnoremap("<leader>gg", ":Neogit<cr>", "open Neogit")
nnoremap("<leader>gl", ":Neogit log<cr>", "Neogit log")
nnoremap("<leader>gp", ":Neogit log<cr>", "Neogit push")

-- diffview
require("diffview").setup({
  enhanced_diff_hl = true,
  view = {
    diff_view = {
      layout = "diff2_vertical",
    },
    file_history = {
      layout = "diff2_vertical",
    },
    merge_tool = {
      layout = "diff4_mixed"
    },
  },
})
nnoremap("<leader>gd", ":DiffviewOpen<cr>", "Diff view")
nnoremap("<leader>gD", ":DiffviewOpen master<cr>", "Diff view master")

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

-- tmux-nvim
require("tmux").setup()

-- nvim-orgmode
require('orgmode').setup({
  org_agenda_files = '~/orgfiles/**/*',
  org_default_notes_file = '~/orgfiles/refile.org',
})

-- render-markdown-nvim
require('render-markdown').setup({
  file_types = { 'markdown', 'gitcommit', 'blink-cmp-documentation' },
  completions = { lsp = { enabled = true } },
  code = {
    style = 'normal',
  },
})

-- nvim-macros
-- Usage:
-- :MacroYank [register]: Yanks a macro from a register. If you don't specify, it'll politely ask you to choose one.
-- :MacroSave [register]: Saves a macro into the book of legends (aka your JSON file). It'll prompt for a register if you're feeling indecisive.
-- :MacroSelect: Brings up your macro menu. Pick one, and it'll be ready for action.
-- :MacroDelete: Summon a list of your macros, then select one to permanently vanish it from your collection, as if it never existed.
require('nvim-macros').setup({
  json_file_path = vim.fs.normalize(vim.fn.stdpath("config") .. "/macros.json"), -- Location where the macros will be stored
  default_macro_register = "q",                                                  -- Use as default register for :MacroYank and :MacroSave and :MacroSelect Raw functions
  json_formatter = "none",                                                       -- can be "none" | "jq" | "yq" used to pretty print the json file (jq or yq must be installed!)
})

-- replaces vim.lsp.inlay_hint.enable(true)
-- (shows types / parameter names at the end of line instead of on the middle of the code)
require("lsp-endhints").setup {
  icons = {
    type = "󰜁 ",
    parameter = "󰏪 ",
    offspec = " ", -- hint kind not defined in official LSP spec
    unknown = " ", -- hint kind is nil
  },
  label = {
    truncateAtChars = 20,
    padding = 1,
    marginLeft = 0,
    sameKindSeparator = ", ",
  },
  extmark = {
    priority = 50,
  },
  autoEnableHints = true,
}
