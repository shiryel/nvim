-- FORKED FROM: https://github.com/valentino-sm/shade.nvim (MIT)

-- KNOWN ISSUES:
-- When closing a session with Diffview open, it will be re-open without Diffview but the window will be set with the option "diff",
-- you can check this behaviour with: "luado inspect(vim.api.nvim_get_option_value("diff", {win = vim.api.nvim_get_current_win()}))"
-- > Removing "localoptions" from "vim.o.sessionoptions" fixes this issue.
--
-- Mouse pass-through does not work on overlays on Neovide

local api                   = vim.api

local E                     = {}
E.DEFAULT_OVERLAY_OPACITY   = 70 -- 0 is full black
E.DEBUG_OVERLAY_OPACITY     = 90
E.DEFAULT_EXCLUDE_FILETYPES = { "DiffviewFiles" }

local state                 = {}
state.active                = false
state.overlays              = {}
state.shade_nsid            = nil

-- Utility functions

local function filter_wininfo(wininfo)
  return {
    relative  = "editor",
    style     = "minimal",
    focusable = false,
    mouse     = false, -- mouse events pass through this window
    row       = wininfo.winrow - 1,
    col       = wininfo.wincol - 1,
    width     = wininfo.width,
    height    = wininfo.height,
    zindex    = 1,
  }
end

local function is_filetype_excluded(filetype)
  for _, value in ipairs(state.exclude_filetypes) do
    if value == filetype then
      return true
    end
  end
  return false
end

local function can_shade(winid)
  if api.nvim_win_is_valid(winid) then
    local buf_id = vim.api.nvim_win_get_buf(winid)
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf_id })
    local diff_enabled = api.nvim_get_option_value("diff", { win = winid })

    if is_filetype_excluded(filetype) or diff_enabled then
      return false
    end

    return true
  else
    return false
  end
end

-- Window management functions

local function create_floatwin(config)
  local window = {}

  window.wincfg = config
  window.bufid = api.nvim_create_buf(false, true)
  window.winid = api.nvim_open_win(window.bufid, false, config)

  return window
end

local function create_overlay_window(winid, config)
  local new_window = create_floatwin(config)
  state.overlays[winid] = new_window

  api.nvim_set_option_value("winhighlight", "Normal:ShadeOverlay", { win = new_window.winid })
  api.nvim_set_option_value("winblend", state.overlay_opacity, { win = new_window.winid })
end

local function remove_overlay_window(winid)
  local overlay = state.overlays[winid]

  if overlay and api.nvim_win_is_valid(overlay.winid) then
    api.nvim_win_close(overlay.winid, true)
    state.overlays[winid] = nil
  end
end

local shade = {}

shade.init = function(opts)
  -- FIXES: neovide applying blur everywhere, but disables pop-ups' blur
  vim.g.neovide_floating_blur_amount_x = 0
  vim.g.neovide_floating_blur_amount_y = 0

  state.overlays = {}

  opts = opts or {}
  state.debug = opts.debug or false

  state.overlay_opacity = opts.overlay_opacity or
      (state.debug == true and E.DEBUG_OVERLAY_OPACITY or
        E.DEFAULT_OVERLAY_OPACITY)
  state.exclude_filetypes = opts.exclude_filetypes or E.DEFAULT_EXCLUDE_FILETYPES

  state.shade_nsid = api.nvim_create_namespace("shade")

  api.nvim_command("highlight ShadeOverlay gui='nocombine' guibg=None")

  api.nvim_set_decoration_provider(state.shade_nsid, { on_win = shade.event_listener })

  shade.autogroups()

  return true
end

shade.autogroups = function()
  vim.api.nvim_create_augroup("shade", { clear = true })

  vim.api.nvim_create_autocmd({ "WinEnter" }, {
    pattern = "*",
    group = "shade",
    callback = function()
      local current_winid = api.nvim_get_current_win()
      local tabpage_winids = {}
      for _, winid in pairs(api.nvim_tabpage_list_wins(0)) do
        tabpage_winids[winid] = true
      end

      -- remove overlay on current window
      remove_overlay_window(current_winid)

      -- cleanup unused overlays
      for id, overlay in pairs(state.overlays) do
        if not tabpage_winids[id] then
          remove_overlay_window(id)
          tabpage_winids[overlay.winid] = nil
        end
      end

      -- create missing overlays
      for winid, _ in pairs(tabpage_winids) do
        if not state.overlays[winid]
            and can_shade(winid)
            and winid ~= current_winid
        then
          -- ignores winid from overlays (otherwise we will create an overlay of an overlay)
          for _, overlay in pairs(state.overlays) do
            if overlay.winid == winid then
              goto ignore_overlay_winid
            end
          end

          local wincfg = api.nvim_call_function("getwininfo", { winid })[1]
          create_overlay_window(winid, filter_wininfo(wincfg))
        end

        ::ignore_overlay_winid::
      end
    end
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = "*",
    group = "shade",
    callback = function()
      local winid = tonumber(vim.fn.expand("<afile>"))
      local overlay = state.overlays[winid]
      if winid and overlay then
        if api.nvim_win_is_valid(overlay.winid) then
          api.nvim_win_close(overlay.winid, false)
          state.overlays[winid] = nil
        end
      end
    end
  })

  -- necessary because a diff window is set as diff after created
  vim.api.nvim_create_autocmd("OptionSet", {
    pattern = "diff",
    group = "shade",
    callback = function()
      local winid = vim.fn.win_getid()
      if api.nvim_get_vvar('option_new') then
        remove_overlay_window(winid)
      end
    end
  })
end

shade.event_listener = function(_, winid, _, _, _)
  local cached = state.overlays[winid]
  if not cached then
    return
  end

  -- check if window dims match cache
  local current_wincfg = vim.api.nvim_call_function("getwininfo", { winid })[1]
  local resize_metrics = { "width", "height", "wincol", "winrow" }
  for _, m in pairs(resize_metrics) do
    if current_wincfg[m] ~= cached.wincfg[m] then
      state.overlays[winid].wincfg = current_wincfg
      pcall(api.nvim_win_set_config, cached.winid, filter_wininfo(current_wincfg))
      goto continue
    end
  end
  ::continue::
end

-- Main

local M = {}

-- For debugging purposes, e.g.:
-- luado require("shade").state.debug = true
-- luado inspect(require("shade").state)
M.state = state

M.setup = function(opts)
  if state.active == true then
    return
  end
  shade.init(opts)
  state.active = true
end

return M
