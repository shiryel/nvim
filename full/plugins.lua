-- helpers
local function nnoremap(bind, command, desc)
  return vim.keymap.set("n", bind, command, { noremap = true, silent = true, desc = desc })
end

-- kanagawa

require('kanagawa').setup({
  undercurl = false,
  colors = {
    theme = { all = { diag = { error = "#727169" } } }, -- fujiGray
  }
})
vim.cmd("colorscheme kanagawa-wave")

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

-- persisted
vim.o.sessionoptions = "buffers,curdir,folds,help,globals,tabpages,winpos,winsize,terminal"
require("persisted").setup({
  autostart = true,

  follow_cwd = true,     -- Change the session file to match any change in the cwd?
  use_git_branch = true, -- Include the git branch in the session file name?
  autoload = true,       -- Automatically load the session for the cwd on Neovim startup?
  autosave = true,

  -- Function to run when `autoload = true` but there is no session to load
  ---@type fun(): any
  on_autoload_no_session = function() end,

  allowed_dirs = { "~/code" }, -- Table of dirs that the plugin will start and autoload from
  ignored_dirs = {},           -- Table of dirs that are ignored for starting and autoloading

  --telescope = {
  --  mappings = { -- Mappings for managing sessions in Telescope
  --    copy_session = "<C-c>",
  --    change_branch = "<C-b>",
  --    delete_session = "<C-d>",
  --  },
  --  icons = { -- icons displayed in the Telescope picker
  --    selected = " ",
  --    dir = "  ",
  --    branch = " ",
  --  },
  --},
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

-- harpoon2
require("harpoon"):setup()

local harpoon = require("harpoon")
nnoremap("<c-a>", function() harpoon:list():add() end, "harpoon: add to list")
nnoremap("<c-s>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, "harpoon: toggle list")
nnoremap("<c-1>", function() harpoon:list():select(1) end, "harpoon: select 1 from list")
nnoremap("<c-2>", function() harpoon:list():select(2) end, "harpoon: select 2 from list")
nnoremap("<c-3>", function() harpoon:list():select(3) end, "harpoon: select 3 from list")
nnoremap("<c-4>", function() harpoon:list():select(4) end, "harpoon: select 4 from list")
nnoremap("<c-5>", function() harpoon:list():select(5) end, "harpoon: select 5 from list")
nnoremap("<c-q>", function() harpoon:list():prev() end, "harpoon: toggle to previous buffer on list")
nnoremap("<c-d>", function() harpoon:list():next() end, "harpoon: toggle to next buffer on list")

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
