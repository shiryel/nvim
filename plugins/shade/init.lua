-- FORKED FROM: https://github.com/valentino-sm/shade.nvim (MIT)

-- TODO: remove all active_overlays on tab change
local api = vim.api

local E = {}
E.DEFAULT_OVERLAY_OPACITY = 70 -- 0 is full black
E.DEBUG_OVERLAY_OPACITY   = 90
E.NOTIFICATION_TIMEOUT    = 1000 -- ms

local state = {}
state.active              = false
state.active_overlays     = {}
state.shade_nsid          = nil
state.notification_timer  = nil
state.notification_window = nil

-- TODO: log to file and/or nvim_echo
local function log(event, msg)
  if state.debug == false then
    return
  end

  msg = tostring(msg)
  local info = debug.getinfo(2, "Sl")
  local line_info = "[shade:" .. info.currentline .. "]"

  local timestamp = ("%s %-15s"):format(os.date("%H:%M:%S"), line_info)
  local event_msg = ("%-10s %s"):format(event, msg)
  print(timestamp .. "  : " .. event_msg)
end

local function filter_wininfo(wininfo)
  return {
    relative  = "editor",
    style     = "minimal",
    focusable = false,
    row    = wininfo.winrow - 1,
    col    = wininfo.wincol - 1,
    width  = wininfo.width,
    height = wininfo.height,
    zindex = 1,
  }
end

--
local function create_hl_groups()
  local overlay_color
  if state.debug == true then
    overlay_color = "#77a992"
  else
    overlay_color = "None"
  end

  api.nvim_command("highlight ShadeOverlay gui='nocombine' guibg=" .. overlay_color)

  -- Link to default hl_group if not user defined
  local exists, _ = pcall(function()
    return vim.api.nvim_get_hl_by_name("ShadeBrightnessPopup", false)
  end)
  if not exists then
    api.nvim_command("highlight link ShadeBrightnessPopup Number")
  end
end

--

local function create_floatwin(config)
  local window = {}

  window.wincfg = config
  window.bufid = api.nvim_create_buf(false, true)
  window.winid = api.nvim_open_win(window.bufid, false, config)

  return window
end

--

local function map_key(mode, key, action)
  local req_module = ("<cmd>lua require'shade'.%s<CR>"):format(action)
  vim.api.nvim_set_keymap(mode, key, req_module, {noremap = true, silent = true})
end


--

local function is_filetype_excluded(filetype)
  for _, value in ipairs(state.exclude_filetypes) do
    if value == filetype then
      return true
    end

  end
  return false
end

local function can_shade(winid)
  if #state.exclude_filetypes == 0 then
    return true
  end
  local buf_id = vim.api.nvim_win_get_buf(winid)
  local filetype = vim.api.nvim_buf_get_option(buf_id, "filetype")

  if is_filetype_excluded(filetype) then
    return false
  end

  return true
end

--

local function shade_window(winid)
  local overlay = state.active_overlays[winid]
  if overlay then
    if api.nvim_win_is_valid(overlay.winid) then
      api.nvim_win_set_option(overlay.winid, "winblend", state.overlay_opacity)
      log("shade_window",
        ("[%d] : overlay %d ON (winblend: %d)"):format(winid, overlay.winid, state.overlay_opacity))
    end
  else
    log("shade_window", "overlay not found for " .. winid)
  end
end

local function unshade_window(winid)
  local overlay = state.active_overlays[winid]
  if overlay then
    if api.nvim_win_is_valid(overlay.winid) then
      api.nvim_win_set_option(overlay.winid, "winblend", 100)
      log("unshade_window",
        ("[%d] : overlay %d OFF (winblend: 100 [disabled])"):format(winid, overlay.winid))
    end
  else
    log("unshade_window", "overlay not found for " .. winid)
  end
end

-- shade everything on a tabpage except current window
local function shade_tabpage(winid)
  winid = winid or api.nvim_get_current_win()
  for overlay_winid, _ in pairs(state.active_overlays) do
    if api.nvim_win_is_valid(overlay_winid) then
      local diff_enabled = api.nvim_win_get_option(overlay_winid, 'diff')
      if overlay_winid ~= winid and diff_enabled == false then
        if can_shade(overlay_winid) then
          log("deactivating window", overlay_winid)
          shade_window(overlay_winid)
        end
      end
    end
  end
end

--

local function remove_all_overlays()
  for _, overlay in pairs(state.active_overlays) do
    if api.nvim_win_is_valid(overlay.winid) then
      api.nvim_win_close(overlay.winid, true)
    end
  end
  state.active_overlays = {}
end


local function create_overlay_window(winid, config)
  local new_window = create_floatwin(config)
  state.active_overlays[winid] = new_window

  api.nvim_win_set_option(new_window.winid, "winhighlight", "Normal:ShadeOverlay")
  api.nvim_win_set_option(new_window.winid, "winblend", state.overlay_opacity)

  log("create overlay",
    ("[%d] : overlay %d created"):format(winid, state.active_overlays[winid].winid))
end

--
local function create_tabpage_overlays(tabid)
  local wincfg
  for _, winid in pairs(api.nvim_tabpage_list_wins(tabid)) do
    wincfg = api.nvim_call_function("getwininfo", {winid})[1]
    if can_shade(winid) then
      create_overlay_window(winid, filter_wininfo(wincfg))
    end
  end
  unshade_window(api.nvim_get_current_win())
end

local shade = {}

-- init
shade.init = function(opts)
  state.active_overlays = {}

  opts = opts or {}
  state.debug = opts.debug or false

  state.overlay_opacity = opts.overlay_opacity or
                            (state.debug == true and E.DEBUG_OVERLAY_OPACITY or
                              E.DEFAULT_OVERLAY_OPACITY)
  state.shade_under_float = opts.shade_under_float or true
  state.exclude_filetypes = opts.exclude_filetypes or {}

  state.shade_nsid = api.nvim_create_namespace("shade")

  local shade_action = {
    ["toggle"] = "toggle()",
  }

  if opts.keys ~= nil then
    for action, key in pairs(opts.keys) do
      if not shade_action[action] then
        log("init:keymap", "unknown action " .. action)
      else
        map_key("n", key, shade_action[action])
      end
    end
  end

  create_hl_groups()

  api.nvim_set_decoration_provider(state.shade_nsid, {on_win = shade.event_listener})

  -- setup autocommands -- TODO: set a precalculated winid
  api.nvim_exec([[
    augroup shade
    au!
    au WinEnter,VimEnter * call v:lua.require'shade'.autocmd('WinEnter',  win_getid())
    au WinClosed         * call v:lua.require'shade'.autocmd('WinClosed', expand('<afile>'))
    au TabEnter          * call v:lua.require'shade'.autocmd('TabEnter',  win_getid())
    au OptionSet         diff call v:lua.require'shade'.autocmd('OptionSet', win_getid())
    au SessionLoadPost   * call v:lua.require'shade'.autocmd('SessionLoadPost')
    augroup END
  ]], false)

  log("Init", "-- Shade.nvim started --")

  return true
end

--

shade.on_win_enter = function(event, winid)
  log(event, winid)
  if not state.active_overlays[winid] then
    local float_cfg = api.nvim_win_get_config(winid)
    if float_cfg["relative"] == "" then
      local wincfg = api.nvim_call_function("getwininfo", {winid})[1]
      create_overlay_window(winid, filter_wininfo(wincfg))
    else
      log(event, "floating window ignored: " .. winid)
      if not state.shade_under_float then
        return
      end
    end
  end

  -- hide the overlay on entered window
  unshade_window(winid)

  -- place overlays on all other windows
  shade_tabpage(winid)
end

shade.event_listener = function(_, winid, _, _, _)
  local cached = state.active_overlays[winid]
  if not cached then
    return
  end

  -- check if window dims match cache
  local current_wincfg = vim.api.nvim_call_function("getwininfo", {winid})[1]
  local resize_metrics = {"width", "height", "wincol", "winrow"}
  for _, m in pairs(resize_metrics) do
    if current_wincfg[m] ~= cached.wincfg[m] then
      log("event_listener: resized", winid)
      state.active_overlays[winid].wincfg = current_wincfg
      pcall(api.nvim_win_set_config, cached.winid, filter_wininfo(current_wincfg))
      goto continue
    end
  end
  ::continue::
end

--
-- destroy overlay window on WinClosed
shade.on_win_closed = function(event, winid)
  winid = tonumber(winid) -- TODO: when did winid become a string?
  local overlay = state.active_overlays[winid]
  if overlay == nil then
    log(event, "no overlay to close")
  else
    log(event, ("trying to close overlay %d"):format(winid))
    if api.nvim_win_is_valid(overlay.winid) then
      api.nvim_win_close(overlay.winid, false)
      log(event, ("[%d] : overlay %d destroyed"):format(winid, overlay.winid))
      if (winid) then
        state.active_overlays[winid] = nil
      end
    end
  end
end

shade.on_session_load_post = function()
    shade.toggle_off()
    vim.schedule(function()
      shade.toggle_on()
    end)
end

shade.toggle_on = function()
  create_tabpage_overlays(0)
  state.active = true
end

shade.toggle_off = function()
  remove_all_overlays()
  state.active = false
end

shade.toggle = function()
  if state.active then shade.toggle_off() else shade.toggle_on() end
end

-- Main
local M = {}

M.setup = function(opts)
  if state.active == true then
    return
  end
  shade.init(opts)
  state.active = true
end

M.toggle = shade.toggle

M.autocmd = function(event, winid)
  if not state.active then
    return
  end
  if (winid) then
    log("AutoCmd: " .. event .. " : " .. winid)
  else
    log("AutoCmd: " .. event)
  end

  local event_fn = {
    ["WinEnter"] = function()
      shade.on_win_enter(event, winid)
    end,
    ["WinClosed"] = function()
      shade.on_win_closed(event, winid)
    end,
    ["TabEnter"] = function()
      remove_all_overlays()
      create_tabpage_overlays(0)
    end,
    ["OptionSet"] = function()
     local diff_enabled = api.nvim_get_vvar('option_new')
     if diff_enabled then
       unshade_window(winid)
       shade_tabpage(winid)
     end
    end,
    ["SessionLoadPost"] = function()
     shade.on_session_load_post()
    end
  }

  local fn = event_fn[event]
  if fn then
    fn()
  end
end

return M
