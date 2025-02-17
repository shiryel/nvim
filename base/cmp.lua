-- omnifunc

local insert_count = 1

local function open_completion()
  local char = vim.v.char

  if char == " " then
    insert_count = 0
  else
    insert_count = insert_count + 1
  end

  if (vim.fn.pumvisible() == 0) and (insert_count >= 2 or char == "." or char == ":") then
    vim.api.nvim_input("<c-x><c-o>")
  end
end

vim.api.nvim_create_autocmd('InsertCharPre', {
  pattern = '*',
  callback = open_completion,
})

vim.opt.completeopt = "menuone,noselect,noinsert,popup"
vim.opt.pumheight = 15 -- keep the pum small

-- popup preview

-- vim.api.nvim_create_autocmd('WinEnter', {
--   pattern = '*',
--   callback = function()
--     inspect(vim.wo.previewwindow)
--     if vim.wo.previewwindow then
--       vim.opt_local.winhighlight = 'Normal:MarkdownError'
--     end
--   end,
-- })
