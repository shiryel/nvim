local function nnoremap(bind, command, desc)
  return vim.keymap.set("n", bind, command, { noremap = true, silent = true, desc = desc })
end

local dap, dapui = require("dap"), require("dapui")
local widgets = require("dap.ui.widgets")

dap.listeners.before.attach.dapui_config = dapui.open
dap.listeners.before.launch.dapui_config = dapui.open
dap.listeners.before.event_terminated.dapui_config = dapui.close
dap.listeners.before.event_exited.dapui_config = dapui.close

nnoremap("<leader>db", dap.toggle_breakpoint, "Toggle breakpoint")
nnoremap("<leader>dB", dap.set_breakpoint, "Set breakpoint")
nnoremap("<leader>dr", dap.repl.open, "Repl open")
nnoremap("<leader>dl", dap.run_last, "Run last")
nnoremap("<leader>dsl", function() dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end,
  "Set log loint message")
nnoremap("<leader>dsc", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
  "Set brealpoint condition")
nnoremap("<leader>dn", dap.continue, "Continue")
nnoremap("<leader>de", dap.step_over, "Step over")
nnoremap("<F3>", dap.step_over, "Step over")
nnoremap("<leader>di", dap.step_into, "Step into")
nnoremap("<F4>", dap.step_into, "Step into")
nnoremap("<leader>do", dap.step_out, "Step out")
nnoremap("<F5>", dap.step_out, "Step out")
nnoremap("<leader>duh", widgets.hover, "Widgets (hover)")
nnoremap("<leader>dup", widgets.preview, "Widgets (preview)")
nnoremap("<leader>duf", function() widgets.centered_float(widgets.frames) end, "Widgets Frames")
nnoremap("<leader>dus", function() widgets.centered_float(widgets.scopes) end, "Widgets Scopes")
nnoremap("<leader>dui", dapui.toggle, "DAP UI toggle")
nnoremap("<leader>dur", function() dapui.open({ reset = true }) end, "DAP UI reset")
nnoremap("<leader>due", function() dapui.eval(vim.fn.input("Eval"), { enter = true }) end, "DAP UI eval")

local sign_define = vim.fn.sign_define
sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpoint" })
sign_define("DapBreakpointCondition", { text = "", texthl = "DapBreakpoint" })
sign_define("DapLogPoint", { text = "", texthl = "DapBreakpoint" })
sign_define("DapBreakpointRejected", { text = "", texthl = "DapBreakpoint" })
sign_define("DapStopped", { text = "󰁕", texthl = "DapStopped" })

require("dapui").setup({
  layouts = {
    {
      elements = {
        'stacks',
        'breakpoints',
        'scopes',
        'watches'
      },
      size = 70,
      position = 'left'
    },
    {
      elements = {
        'repl',
        'console'
      },
      size = 12,
      position = 'bottom'
    }
  }
})

--require("nvim-dap-virtual-text").setup()

-- ELIXIR

dap.adapters.mix_task = {
  type = 'executable',
  command = 'elixir-debug-adapter',
  args = {}
}

dap.configurations.elixir = {
  {
    type = "mix_task",
    name = "mix test",
    task = 'test',
    taskArgs = { "--trace" },
    request = "launch",
    startApps = true,
    projectDir = "${workspaceFolder}",
    requireFiles = {
      "test/**/test_helper.exs",
      "test/**/*_test.exs"
    }
  }
}

-- C / CPP

dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "-i", "dap" },
}

local cxxConfig = {
  name = "Launch",
  type = "gdb",
  request = "launch",
  program = function()
    local cwd = vim.fn.getcwd()
    return vim.fn.input("Path to executable: ", cwd .. "/bin/" .. vim.fs.basename(cwd), "file")
  end,
  cwd = "${workspaceFolder}",
  stopAtBeginningOfMainSubprogram = false,
}

dap.configurations.c = {
  cxxConfig,
}

dap.configurations.cpp = {
  cxxConfig,
}

-- RUST

dap.adapters.rust_gdb = {
  type = "executable",
  name = "gdb";
  command = "rust-gdb",
  args = { "-i", "dap" },
}

dap.adapters.lldb = {
  type = "executable",
  name = "lldb";
  command = "lldb-vscode",
}

dap.configurations.rust = {
  {
    name = "Launch",
    type = "lldb",
    request = "launch",
    program = function()
      local cwd = vim.fn.getcwd()
      return vim.fn.input("Path to executable: ", cwd .. "/target/debug/" .. vim.fs.basename(cwd), "file")
    end,
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  },
}

-- PYTHON

--dap.adapters.python = {
--  type = 'executable',
--  command = os.getenv('HOME') .. '/.virtualenvs/tools/bin/python',
--  args = { '-m', 'debugpy.adapter' },
--}

--dap.configurations.python = {
--  {
--    type = 'python';
--    request = 'launch';
--    name = "Launch file";
--    program = "${file}";
--    pythonPath = function()
--      return '/usr/bin/python'
--    end;
--  },
--}

-- JAVA

--dap.adapters.java = function(callback, config)
--   M.execute_command({command = 'vscode.java.startDebugSession'}, function(err0, port)
--     assert(not err0, vim.inspect(err0))
--     callback({ type = 'server'; host = '127.0.0.1'; port = port; })
--   end)
-- end
