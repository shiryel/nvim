local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup.cmdline('/', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp_document_symbol' }
  }, {
    { name = 'buffer' }
  })
})

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
  --view = {
  --  entries = 'native' -- can be "custom", "wildmenu" or "native"
  --},
  experimental = {
    ghost_text = false,
    native_menu = false,
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
          --luasnip.expand()
          cmp.confirm({ select = true })
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
          if vim.fn.hlID(group) < 1 then
            vim.api.nvim_set_hl(0, group, { fg = '#' .. hex })
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
