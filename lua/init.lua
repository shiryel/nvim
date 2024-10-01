function inspect(...)
  -- :message
  return print(vim.inspect(...))
end

pcall(vim.lsp.inlay_hint.enable)
