-- BASED ON: https://github.com/kosayoda/nvim-lightbulb (MIT)

local LIGHTBULB_GROUP = "lightbulb"
local LIGHTBULB_SIGN = "LightBulbSign"
local CODELENS_SIGN = "LightBulbSign"

local M = {}

M.setup = function()
  if vim.tbl_isempty(vim.fn.sign_getdefined(LIGHTBULB_SIGN)) then
    vim.fn.sign_define(LIGHTBULB_SIGN, { text = "", texthl = "LspDiagnosticsDefaultInformation" })
  end
  if vim.tbl_isempty(vim.fn.sign_getdefined(CODELENS_SIGN)) then
    vim.fn.sign_define(CODELENS_SIGN, { text = "", texthl = "LspDiagnosticsDefaultInformation" })
  end

  vim.api.nvim_create_augroup(LIGHTBULB_GROUP, { clear = true })
  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    group = LIGHTBULB_GROUP,
    pattern = "*",
    callback = function()
      local buf = vim.api.nvim_get_current_buf()

      -- Check for code action capability
      local code_action_cap_found = false
      for _, _ in pairs(vim.lsp.get_clients({ bufnr = buf, method = "textDocument/codeAction" })) do
        code_action_cap_found = true
      end
      if not code_action_cap_found then
        return
      end

      local lsp_util = require("vim.lsp.util")
      local context = { diagnostics = vim.diagnostic.get(0) }
      context.only = { "quickfix" } -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#codeActionKind

      local params = lsp_util.make_range_params(0, "utf-8")
      ---@diagnostic disable-next-line: inject-field
      params.context = context
      -- by receiving all requests at once we prevent one server response to override the other
      vim.lsp.buf_request_all(0, 'textDocument/codeAction', params,
        function(responses)
          M.handle_lightbulb(responses, params.range.start, buf)
        end)
    end
  })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    pattern = { "*" },
    group = LIGHTBULB_GROUP,
    callback = function(args)
      M.clear_lightbulb(args.buf)
    end,
  })
end

M.handle_lightbulb = function(responses, position, buf)
  local has_actions = false
  for _, resp in pairs(responses) do
    if resp.result and not vim.tbl_isempty(resp.result) then
      has_actions = true
      break
    end
  end

  if not has_actions then
    M.clear_lightbulb(buf)
    return
  end

  -- Avoid redrawing lightbulb if the code action line did not change
  local line = position.line + 1
  if vim.b[buf].lightbulb_line ~= line then
    M.clear_lightbulb(buf)
    if M.is_code_lens(position) then
      vim.fn.sign_place(line, LIGHTBULB_GROUP, CODELENS_SIGN, buf, { lnum = line, priority = 10 })
    else
      vim.fn.sign_place(line, LIGHTBULB_GROUP, LIGHTBULB_SIGN, buf, { lnum = line, priority = 10 })
    end
    vim.b[buf].lightbulb_line = line
  end
end

M.clear_lightbulb = function(buf)
  vim.fn.sign_unplace(LIGHTBULB_GROUP, { id = vim.b.lightbulb_line, buffer = buf })
  vim.b[buf].lightbulb_line = nil
end

M.is_code_lens = function(position)
  local codelens_actions = {}
  for _, l in ipairs(vim.lsp.codelens.get(0)) do
    table.insert(codelens_actions, { start = l.range.start, finish = l.range["end"] })
  end

  for _, action in ipairs(codelens_actions) do
    if action.start.line <= position.line and position.line <= action.finish.line and action.start.character <= position.col and position.col <= action.finish.character then
      return true
    end
  end
  return false
end

return M
