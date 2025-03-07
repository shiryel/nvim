# FROM: https://github.com/Kicamon/ranger.nvim (MIT)

local api = vim.api
local win = require('ranger.window')
local infos = {}
local config = {}

local set_split = {
  ['left'] = 'nosplitright',
  ['down'] = 'splitbelow',
  ['up'] = 'nosplitbelow',
  ['right'] = 'splitright',
}

local function defualt()
  return {
    width = 0.8,
    height = 0.8,
    title = ' Ranger ',
    relative = 'editor',
    row = 'c',
    col = 'c',
  }
end

local function open_file(open, opt)
  if opt then
    vim.cmd.set(set_split[opt])
  end

  if vim.fn.filereadable(vim.fn.expand(infos.tempname)) == 1 then
    local filenames = vim.fn.readfile(infos.tempname)
    for _, filename in ipairs(filenames) do
      vim.cmd(open .. ' ' .. filename)
    end
  end
end

local function end_options()
  vim.fn.delete(infos.tempname)
  vim.cmd('silent! lcd ' .. infos.workpath)
end

local function ranger(open, opt)
  infos.workpath = vim.fn.getcwd()
  infos.tempname = vim.fn.tempname()

  vim.cmd('silent! lcd %:p:h')

  local float_opt = config

  if infos.bufnr then
    float_opt.bufnr = infos.bufnr
    api.nvim_set_option_value('modified', false, { buf = infos.bufnr })
  end

  infos.bufnr, infos.winid =
    win:new_float(float_opt, true, true):bufopt('bufhidden', 'hide'):wininfo()

  vim.cmd('startinsert')

  vim.fn.termopen(string.format('ranger --choosefiles="%s"', infos.tempname), {
    on_exit = function()
      if api.nvim_win_is_valid(infos.winid) then
        api.nvim_win_close(infos.winid, true)
        open_file(open, opt)
      end
      infos.winid = nil
      end_options()
    end,
  })
end

local commands = {
  left = function()
    ranger('vsplit', 'left')
  end,
  down = function()
    ranger('split', 'down')
  end,
  up = function()
    ranger('split', 'up')
  end,
  right = function()
    ranger('vsplit', 'right')
  end,
}

local function load_command(cmd)
  commands[cmd]()
end

local function commands_list()
  return vim.tbl_keys(commands)
end

local function setup(opts)
  config = vim.tbl_extend('force', defualt(), opts or {})

  if config.pos then
    config.row = config.win.pos:sub(1, 1)
    config.col = config.win.pos:sub(2, 2)
    config.pos = nil
  end

  api.nvim_create_user_command('Ranger', function(args)
    if #args.args == 0 then
      ranger('edit')
    else
      load_command(args.args)
    end
  end, {
    range = true,
    nargs = '?',
    complete = function(arg)
      local list = commands_list()
      return vim.tbl_filter(function(s)
        return string.match(s, '^' .. arg)
      end, list)
    end,
  })
end

return { setup = setup }
