local blink = require("blink.cmp")

-- Allows a markdown render to work on blink
-- https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/402#issuecomment-2905782858
vim.treesitter.language.register('markdown', 'blink-cmp-documentation')

blink.setup({
  -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
  -- 'super-tab' for mappings similar to vscode (tab to accept)
  -- 'enter' for enter to accept
  -- 'none' for no mappings
  --
  -- All presets have the following mappings:
  -- C-space: Open menu or open docs if already open
  -- C-n/C-p or Up/Down: Select next/previous item
  -- C-e: Hide menu
  -- C-k: Toggle signature help (if signature.enabled = true)
  --
  -- See :h blink-cmp-config-keymap for defining your own keymap
  keymap = {
    preset = 'enter',
    ['<C-tab>'] = { function(cmp) cmp.show() end },
    ['<C-space>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
    ['<C-up>'] = { function(cmp) cmp.scroll_documentation_up(4) end },
    ['<C-down>'] = { function(cmp) cmp.scroll_documentation_down(4) end },
  },

  appearance = {
    -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = 'mono'
  },

  completion = {
    -- Don't select by default, auto insert on selection
    list = { selection = { preselect = false, auto_insert = true } },
    -- Display a preview of the selected item on the current line
    ghost_text = { enabled = true },
    -- Show the documentation popup when manually triggered
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 60,
    },
    -- 'full' will fuzzy match on the text before _and_ after the cursor
    -- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
    keyword = { range = 'full' },
  },

  -- loads friendly-snippets
  snippets = { preset = 'default' },

  signature = { enabled = true },

  -- https://cmp.saghen.dev/configuration/reference#cmdline
  cmdline = {
    enabled = true,
    keymap = { preset = 'inherit' },
    sources = { 'buffer', 'cmdline' },
    completion = {
      -- Don't select by default, auto insert on selection
      list = { selection = { preselect = false, auto_insert = true } },
      ghost_text = { enabled = false },
      menu = { auto_show = function(_, _) return true end },
    },
  },

  -- https://cmp.saghen.dev/configuration/reference#terminal
  term = {
    enabled = true,
    keymap = { preset = 'inherit' },
  },

  -- https://cmp.saghen.dev/configuration/reference#sources
  sources = {
    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    default = { 'lsp', 'path', 'snippets', 'buffer' },

    providers = {
      lsp = {
        async = true, -- show the completions before this provider returns
        --fallbacks = {}, -- force enable buffer source even when LSP results are available
      },
      path = {
        opts = {
          show_hidden_files_by_default = true,
          -- Path completion from cwd instead of current buffer's directory
          get_cwd = function(_)
            return vim.fn.getcwd()
          end,
        }
      },
      snippets = {
        opts = {
          use_label_description = true,
        }
      },
      buffer = {
        opts = {
          -- Get completion from all "normal" buffers open
          get_bufnrs = function()
            return vim.tbl_filter(function(bufnr)
              return vim.bo[bufnr].buftype == ''
            end, vim.api.nvim_list_bufs())
          end
        }
      },
    },

    -- https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/514#issuecomment-3290234734
    per_filetype = {
      markdown = { inherit_defaults = true },
    },
  },

  -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
  -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
  -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
