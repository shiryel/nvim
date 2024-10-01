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

-- FZF does not work with live_grep
-- :Telescope fzf is a bug
-- Needs to be called right after telesctope to get fzf loaded
--require('telescope').load_extension('fzf')

local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

require('kanagawa').setup({
  undercurl = false,
  colors = {
    theme = { all = { diag = { error = "#727169" } } }, -- fujiGray
  }
})

cmd("colorscheme kanagawa-wave")

require('mini.statusline').setup({})
-- https://github.com/rebelot/kanagawa.nvim?tab=readme-ov-file#color-palette
api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#363646" })

require('mini.indentscope').setup({
  draw = {
    animation = function(_, _) return 10 end -- ms between each step
  }
})

-- see: https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#loaders
-- Using an empty {} will use runtimepath, check it with: :lua =vim.opt.runtimepath._value
-- Check logs with: :lua require("luasnip").log.open()
require("luasnip.loaders.from_vscode").lazy_load({ paths = { "/etc/nvim/snippets" } })
--require("luasnip").config.setup({
--  enable_autosnippets = true
--})

-- Icons for CMP
local kind_icons = {
  Text = "",
  Function = "󰊕",
  Method = "󰡱",
  Constructor = "",
  Field = "",
  Variable = "",
  Class = "",
  Interface = "",
  Module = "",
  Property = "",
  Unit = "",
  Value = "󰀬",
  Enum = "",
  EnumMember = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  Constant = "",
  Struct = "",
  Event = "",
  Operator = "",
  TypeParameter = ""
}

local luasnip = require("luasnip")
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      -- NOTE: Nvim has native snippets, but they are minimal, made to only support the LSP snippets
      require('luasnip').lsp_expand(args.body)
    end
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered()
  },
  view = {
    entries = "custom" -- can be "custom", "wildmenu" or "native"
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping(function(fallback)
      if luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      elseif cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<CR>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if luasnip.expandable() then
          luasnip.expand()
        else
          cmp.confirm({ select = true })
        end
      else
        fallback()
      end
    end),
    ['<C-up>'] = cmp.mapping.scroll_docs(-4),
    ['<C-down>'] = cmp.mapping.scroll_docs(4),
    ["<C-tab>"] = cmp.mapping.complete(),
    -- ['<C-c>'] = cmp.mapping.abort(),
  }),
  sources = cmp.config.sources({
      { name = 'nvim_lsp_signature_help' },
      { name = "nvim_lsp" },
      { name = "luasnip" }, --, option = { show_autosnippets = true }
      { name = 'buffer' },
      { name = 'path' },
      --{ name = 'omni' },
      { name = 'nvim_lua' }
    },
    { { name = "buffer" } }
  ),
  formatting = {
    format = function(entry, vim_item)
      -- Source
      vim_item.menu = ({
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        luasnip = "[LuaSnip]",
        nvim_lua = "[Lua]",
        latex_symbols = "[LaTeX]",
      })[entry.source.name]

      if vim_item.kind == 'Color' and entry.completion_item.documentation then
        local hex = string.sub(entry.completion_item.documentation, 2)
        if hex then
          local group = 'Tw_' .. hex
          if fn.hlID(group) < 1 then
            api.nvim_set_hl(0, group, { fg = '#' .. hex })
          end
          vim_item.kind = "■ Color" -- or "⬤" or anything
          vim_item.kind_hl_group = group
        end
      else
        -- Kind icons
        vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
      end

      return vim_item
    end
  }
})

cmp.setup.cmdline('/', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp_document_symbol' }
  }, {
    { name = 'buffer' }
  })
})

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

require("aerial").setup({
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "[[", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "]]", "<cmd>AerialNext<CR>", { buffer = bufnr })
  end,
})

require("nvim-tree").setup({
  on_attach = function(bufnr)
    -- use :NvimTreeGenerateOnAttach to generate this function
    local function noremap(bind, command, desc)
      return vim.keymap.set("n", bind, command,
        { buffer = bufnr, noremap = true, silent = true, nowait = true, desc = 'nvim-tree: ' .. desc })
    end
    local api = require('nvim-tree.api')
    api.config.mappings.default_on_attach(bufnr) -- default mapping

    noremap('<C-up>', api.tree.change_root_to_parent, "Dir up")
    noremap('s', api.node.open.vertical, "Open: Vertical Split")
    noremap('v', api.node.open.horizontal, "Open: Horizontal Split")
    noremap('?', api.tree.toggle_help, "Help")
    noremap('P',
      function()
        local node = api.tree.get_node_under_cursor()
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

require("ccc").setup({
  highlighter = {
    auto_enable = true
  }
})
