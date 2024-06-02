function inspect(...)
  -- :message
  return print(vim.inspect(...))
end

vim.lsp.inlay_hint.enable()

vim.cmd("colorscheme kanagawa")
