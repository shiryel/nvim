function inspect(...)
  -- :message
  return print(vim.inspect(...))
end

-------------
-- Options --
-------------

local g = vim.g
local o = vim.opt
local c = vim.cmd

c("highlight Comment cterm=italic")
c("hi link xmlEndTag xmlTag")
c("hi htmlArg gui=italic")
c("hi Comment gui=italic")
c("hi Type gui=italic")
c("hi htmlArg cterm=italic")
c("hi Comment cterm=italic")
c("hi Type cterm=italic")

-- Transparent Background
--c("highlight Normal guibg=none")
--c("highlight NonText guibg=none")

if g.neovide then
  g.neovide_hide_mouse_when_typing = 1
  g.neovide_input_use_logo = 1 -- see: https://github.com/neovide/neovide/pull/857
end

o.guifont = { "Cousine Nerd Font Mono", ":h11" }

-- to work with 16M colors schemes in the terminal
o.termguicolors = true

-- Spaces and Tabs
o.syntax = "enable"
o.expandtab = true
o.tabstop = 2     -- Spaces that a tab counts for
o.softtabstop = 2 -- Spaces that a tab counts when editing
o.shiftwidth = 2  -- Spaces to use for each step of (auto)indent

-- UI Config
pcall(vim.lsp.inlay_hint.enable)
o.encoding = "utf8"
o.number = true
o.relativenumber = true -- line number is relative to cursor
o.mouse = "a"           -- enable mouse
o.cursorline = true     -- highlight the current cursor line
o.cursorcolumn = false  -- highlight the current cursor column
o.smartindent = true    -- smart ident (priority for C like langs)
o.autoindent = true     -- copy the ident of current line when using the o or O commands
o.wrap = true           -- continue long lines in the next line
o.linebreak = true
o.lazyredraw = false    -- screen will not redrawn while exec macros, registers or not typed commands
o.showmatch = false     -- jump to a match when executed
o.showmode = false      -- lightline shows the status not vim
o.showtabline = 2       -- always show files with tab page labels
o.shortmess =
"acAF"                  -- avoid hit-enter prompts, a = abbreviation without loss, c = avoid showing message extra message when using completion, A = don't give the "ATTENTION" message when an existing swap file is found, F = don't give the file info when editing a file.
o.updatetime = 300      -- time (ms) to save in swap.  You will have bad experience for diagnostic messages when it's default 4000.
o.signcolumn = "yes"    -- column for error signs
o.showcmd = true        -- show commands in the last line off screen
o.cmdheight = 1         -- needs >0 to not ask for interaction when displaying messages
o.scrolloff = 3         -- centers the cursor when moving
-- give us a realtime preview of substitution before we send it "set list " show formating characters
o.inccommand = "nosplit"
o.lcs = "eol:\194\172,extends:\226\157\175,precedes:\226\157\174,tab:>-" -- the formating characters

-- enables virtual text/lines diagnostic to only current line
vim.diagnostic.config({
  virtual_text = { current_line = true },
  --virtual_lines = { current_line = true },
})

-- StatusLine
-- F to full name
o.statusline = "%f%m%r%h%w %=%< [%Y] [0x%02.2B]%4v,%4l %3p%% of %L"
o.ruler = false  -- hide the column and line of the pointer
o.laststatus = 2 -- always shows the status line on other windows

-- Backup / History
o.backup = false          -- no backup file when overwriting
o.writebackup = false     -- no make backup before overwriting
o.swapfile = true         -- enable swapfile (dont use it with confidential information, that even root must not be able to acess!)
o.hidden = true           -- buffer continue to exists when the file is abandoned
o.history = 100           -- history of the : commands
do end
(o.path):append({ "**" }) -- list of directories which will be searched when using the |gf|, [f, ]f, ^Wf, |:find|, |:sfind|, |:tabfind| and other commands

-- Split / Diff
o.splitbelow = true    -- default split below
o.diffopt = "vertical" -- default diff split in the vertical

-- Searching
o.incsearch = true  -- show when typing
o.hlsearch = true   -- highlight
o.smartcase = false -- do not override the ignorecase option
o.ignorecase = true -- ignorecase option :P

-- completion
o.wildmenu = true                 -- menu inline
o.wildmode = "full,list:lastused" -- full fist because is how the plugin works

-- ignore on tab completing
vim.opt.wildignore:append({ "*.o", "*~", ".**", "build/**", "log/**", "tmp/**" })

-- Set <Leader>
g.mapleader = " "

-------------
-- Configs --
-------------

local function noremap(bind, command, desc)
  return vim.keymap.set("", bind, command, { noremap = true, silent = true, desc = desc })
end

local function nnoremap(bind, command, desc)
  return vim.keymap.set("n", bind, command, { noremap = true, silent = true, desc = desc })
end

local function inoremap(bind, command, desc)
  return vim.keymap.set("i", bind, command, { noremap = true, expr = true, desc = desc })
end

local function cnoremap(bind, command, desc)
  return vim.keymap.set("c", bind, command, { noremap = true, silent = true, expr = true, desc = desc })
end

local function vnoremap(bind, command, desc)
  return vim.keymap.set("v", bind, command, { noremap = true, silent = true, desc = desc })
end

local function tnoremap(bind, command, desc)
  return vim.keymap.set("t", bind, command, { noremap = true, silent = true, desc = desc })
end

-- Folding
-- (we use aerial to navigate and fold to handle HTML)
o.foldmethod = "expr"
o.foldexpr = "nvim_treesitter#foldexpr()"
o.foldenable = false -- use zi to togle folding
o.foldlevelstart = 1 -- some folds closed when start editing (1)
o.foldnestmax = 20   -- limit the folds in the indent and syntax
o.foldminlines = 1   -- limit the folds in the indent and syntax

--nnoremap("<leader>z", "za", "Toogle folder under cursor")
--nnoremap("<leader>Z", "zA", "Toogle all folders under cursor")

-- Spell
-- :set spell – Turn on spell checking
-- :set nospell – Turn off spell checking
-- z= – Bring up the suggested replacements
-- zg – Good word: Add the word under the cursor to the dictionary
-- zw – Woops! Undo and remove the word from the dictionary
o.spell = true
--nnoremap("<leader>n", "]]s<cr>", "Jump to the next misspelled word")
--nnoremap("<leader>N", "]]s<cr>", "Jump to the previous misspelled word")

-- Buffer moves
nnoremap("<c-left>", "<c-w><c-h>")
nnoremap("<c-down>", "<c-w><c-j>")
nnoremap("<c-up>", "<c-w><c-k>")
nnoremap("<c-right>", "<c-w><c-l>")

-- Buffer changes
nnoremap("<c-b>", ":bp<cr>", "previous buffer")
nnoremap("<c-B>", ":bn<cr>", "next buffer")

nnoremap("<Tab>", "gt", "next tab")

-- Clipboard

-- see: https://github.com/ibhagwan/fzf-lua/issues/808#issuecomment-1620955734
vim.keymap.set('t', '<c-r>', [['<C-\><C-N>"'.nr2char(getchar()).'pi']], { expr = true, desc = "registers" })

noremap("<leader>y", "\"+y", "system copy")
noremap("<leader>p", "\"+p", "system paste")

if g.neovide then
  -- see: https://github.com/neovide/neovide/issues/113#issuecomment-2106304788
  vim.keymap.set('v', '<sc-c>', '"+y', { noremap = true, desc = "system copy" })
  vim.keymap.set('n', '<sc-v>', 'l"+P', { noremap = true, desc = "system paste" })
  vim.keymap.set('v', '<sc-v>', '"+P', { noremap = true, desc = "system paste" })
  vim.keymap.set('c', '<sc-v>', '<C-o>l<C-o>"+<C-o>P<C-o>l', { noremap = true, desc = "system paste" })
  vim.keymap.set('i', '<sc-v>', '<ESC>l"+Pli', { noremap = true, desc = "system paste" })
  vim.keymap.set('t', '<sc-v>', '<C-\\><C-n>"+Pi', { noremap = true, desc = "system paste" })
end

-- Unselect
nnoremap("<leader><leader>", ":noh<cr>", "unselect")

-- Convert existing tabs to spaces
nnoremap("<c-tab>", ":retab<cr>", "tabs to spaces")

-- Open terminal
--nnoremap("<leader>T", ":sp <Bar> :terminal<cr> <bar> i", "open terminal")
--nnoremap("<c-t>", ":botright terminal<cr> <bar> i", "open terminal")
--tnoremap("<Esc>", "<C-\\><C-n>", "normal mode") -- NOTE: breaks ranger
--tnoremap("<c-up>", "<C-\\><C-n><c-w><c-k>", "navigate up")

-- Completion Menu --
-- <C-i> - open
-- <C-n> - next
-- <C-p> - previous
-- NOTE: <Tab> == <C-i>
cnoremap("<down>", "wildmenumode() ? \"<c-n>\" : \"<down>\"", "down")
cnoremap("<up>", "wildmenumode() ? \"<c-p>\" : \"<up>\"", "up")

c("au BufRead,BufNewFile *.colortemplate set filetype=colortemplate")

c("au BufRead,BufNewFile *.fnl set filetype=clojure")
c("au BufRead,BufNewFile *.ex set filetype=elixir")
c("au BufRead,BufNewFile *.exs set filetype=elixir")
c("au BufRead,BufNewFile *.slime set filetype=elixir")
c("au BufRead,BufNewFile *.zig set filetype=zig")

c("au FileType elm set tabstop=4")
c("au FileType elm set shiftwidth=4")
c("au FileType elm set expandtab")

c("au FileType elm set tabstop=2")
c("au FileType elm set shiftwidth=2")
c("au FileType gdscript set noexpandtab")

c("au BufNewFile,BufRead *.yrl set filetype=erlang")
c("au BufNewFile,BufRead *.xrl set filetype=erlang")

-- Netrw

--local options_append = {
--  netrw_keepdir = 0,             --Keep the current directory and the browsing directory synced
--  netrw_winsize = "17",          -- 17% size
--  netrw_banner = "0",            -- hide banner
--  netrw_localmkdir = "mkdir -p", -- change mkdir cmd
--  netrw_localcopycmd = "cp -r",  -- change copy command
--  netrw_localrmdir = "rm -r",    -- change delete command
--  netrw_list_hide = [['\(^\|\s\s\)\zs\.\S\+']],
--}
--
--for k, v in pairs(options_append) do
--  g[k] = v
--end
--
--vim.api.nvim_create_autocmd("filetype", {
--  pattern = "netrw",
--  callback = function()
--    local bind = function(lhs, rhs)
--      vim.keymap.set("n", lhs, rhs, { remap = true, buffer = true })
--    end
--
--    -- Navigation
--    bind("h", "a")                     -- Cycles between normal display, hiding and showing
--    bind("p", "u")                     -- preview dir
--    bind("<C-up>", "-^")               -- go up
--    bind(".", "gh")                    -- toggle dotfiles
--    bind("<leader>E", ":Lexplore<CR>") -- close if open
--
--    -- Marks
--    bind("<TAB>", "mf")         -- toggle mark
--    bind("<S-TAB>", "mF")       -- unmark
--    bind("<leader><TAB>", "mu") -- unmark all
--
--    -- Files
--    bind("a", ":!touch ") -- create file
--    --bind("fd", ":!mkdir -p ") -- create folder
--    --bind("fc", ":!cp -r ")    -- copy
--    --bind("D", ":!rm -r ")   -- delete
--
--    -- Disable
--    bind("C", "<NOP>")  -- Setting the editing window
--    bind("d", "<NOP>")  -- Make a directory
--    bind("gd", "<NOP>") -- Force treatment as directory
--    bind("gf", "<NOP>") -- Force treatment as file
--    bind("I", "<NOP>")  -- Toggle the displaying of the banner
--    bind("O", "<NOP>")  -- Obtain a file specified by cursor
--    bind("p", "<NOP>")  -- Preview the file
--    bind("P", "<NOP>")  -- Browse in the previously used window
--    bind("%", "<NOP>")  -- Open a new file in netrw's current directory
--  end,
--})
--
--nnoremap("<leader>E", ":Lexplore<CR>", "toggle file tree")
