-- BASED ON:
-- https://github.com/Kicamon/nvim/blob/main/colors/gruvbox.lua (MIT)
-- https://github.com/rebelot/kanagawa.nvim (MIT)
-- https://github.com/Rydwxz/bhs/blob/main/lua/black_hole_sun/theme.lua

if vim.g.colors_name then
  vim.cmd("hi clear")
end
vim.o.termguicolors = true

local c = {
  -- Color naming based on https://en.wikipedia.org/wiki/Color_term

  gray_0 = "#000108",
  gray_1 = "#010416",
  gray_2 = "#070c1f",
  gray_3 = "#141728",
  gray_4 = "#1f1f28",
  gray_5 = "#282c3d",
  gray_6 = "#3b4157",
  gray_7 = "#4d556f",
  gray_8 = "#616b89",
  gray_9 = "#79829c",
  gray_10 = "#9299b3",
  gray_11 = "#a5acc0",
  gray_12 = "#c2c7d3",
  gray_13 = "#ced1d8",

  fg = "#cac6ab",

  red = "#ff6f6f",
  --red_gb = "#472d35", -- 18% on gray_4
  orange = "#e29588",
  yellow = "#e0da8d",
  yellow_bg = "#42413a", -- 18% on gray_4
  chartreuse = "#9fc03b",
  chartreuse_l = "#c1ed3a",
  green = "#b0db70",
  green_bg = "#394135", -- 18% on gray_4
  green_l = "#46dc44",
  --spring = "#54b584",
  cyan = "#acc6ec",
  cyan_bg = "#383d4b", -- 18% on gray_4
  --azure = "#6cb6ff",
  blue = "#74a5f0",
  violet = "#a88df7",
  magenta = "#c77fcd",
  rose = "#ff77bb",
}

-- NOTE: Use :Inspect to see what highlight group something is using!
--
-- This color scheme has a base on blue/violet with 3 main colors:
-- Magenta - keywords : the language itself
-- Violet - modules : how the code is organized
-- Blue - functions : abstractions, composes modules
-- cyan - text : common stuff, composes abstractions
--
-- And then we use accents for:
-- green - strings
-- yellow - numbers / bool / labels
-- orange - delimiters
--
-- Why no white color for the text? Because it mixes with other colors, like yellow

local a = {
  -- structure
  panel_border = c.gray_0,
  popup_border = c.gray_1,
  popup_bg = c.gray_2,
  panel_bg = c.gray_4,

  -- intermediary
  line_bump = c.gray_5, -- folds / title bg
  current_place = c.gray_6,
  selection = c.gray_7,
  cursor_bg = c.gray_8,
  panel_border_focus = c.gray_8,

  -- text
  comment = c.gray_9,
  text_no_focus = c.gray_10,
  text = c.cyan,

  -- other
  scrollbar = c.cyan,

  ---------------
  -- Languages --
  ---------------

  -- Structural, Stable
  fn_def = c.magenta,
  fn = c.blue,
  constant = c.cyan,
  type = c.cyan,
  module = c.violet,
  number = c.yellow, -- int / float
  bool = c.yellow,
  label = c.yellow,  -- label / atoms

  -- Volatile, Unstable
  operator = c.magenta,
  keyword = c.magenta,
  meta_attribute = c.violet,
  regex = c.rose,
  delimiter = c.orange, -- () / {} / []

  -- Composition Terms (Neutral)
  string = c.green,
  uri = c.green,
  wildcard = c.green,
}

local groups = {
  -- FROM: *highlight-groups* *highlight-default*
  -- These are the builtin highlighting groups.  Note that the highlighting depends
  -- on the value of 'background'.  You can see the current settings with the
  -- ":highlight" command.

  ['ColorColumn'] = {},                                            -- Used for the columns set with 'colorcolumn'.
  ['Conceal'] = {},                                                -- Placeholder characters substituted for concealed text (see 'conceallevel').
  ['CurSearch'] = {},                                              -- Current match for the last search pattern (see 'hlsearch'). Note: This is correct after a search, but may get outdated if changes are made or the screen is redrawn.
  ['Cursor'] = { bg = a.cursor_bg, fg = a.text },                  -- Character under the cursor.
  ['lCursor'] = { link = 'Cursor' },                               -- Character under the cursor when |language-mapping| is used (see 'guicursor').
  ['CursorIM'] = { link = 'Cursor' },                              -- Like Cursor, but used when in IME mode.
  ['CursorColumn'] = { bg = a.current_place },                     -- Screen-column at the cursor, when 'cursorcolumn' is set.
  ['CursorLine'] = { bg = a.current_place },                       -- Screen-line at the cursor, when 'cursorline' is set. Low-priority if foreground (ctermfg OR guifg) is not set.
  ['Directory'] = { fg = c.green_l },                              -- Directory names (and other special names in listings).
  ['DiffAdd'] = { bg = c.green_bg },                               -- Diff mode: Added line. |diff.txt|
  ['DiffChange'] = { bg = c.cyan_bg },                             -- Diff mode: Changed line. |diff.txt|
  ['DiffDelete'] = { bg = c.red_bg },                              -- Diff mode: Deleted line. |diff.txt|
  ['DiffText'] = { bg = c.yellow_bg },                             -- Diff mode: Changed text within a changed line. |diff.txt|
  ['EndOfBuffer'] = {},                                            -- Filler lines (~) after the end of the buffer. By default, this is highlighted like |hl-NonText|.
  ['TermCursor'] = { link = 'Cursor' },                            -- Cursor in a focused terminal.
  ['ErrorMsg'] = { fg = c.red },                                   -- Error messages on the command line.
  ['WinSeparator'] = { fg = a.panel_border, bg = a.panel_border }, -- Separators between window splits.
  ['Folded'] = { bg = a.line_bump },                               -- Line used for closed folds.
  ['FoldColumn'] = { bg = a.line_bump },                           -- 'foldcolumn'
  ['SignColumn'] = { bg = a.panel_bg },                            -- Column where |signs| are displayed.
  ['IncSearch'] = { bg = c.selection },                            -- 'incsearch' highlighting; also used for the text replaced with ":s///c".
  ['Substitute'] = { fg = c.gray_1, bg = c.chartreuse_l },         -- |:substitute| replacement text highlighting.
  ['LineNr'] = { fg = a.comment },                                 -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
  ['LineNrAbove'] = { link = 'LineNr' },                           -- Line number for when the 'relativenumber' option is set, above the cursor line.
  ['LineNrBelow'] = { link = 'LineNr' },                           -- Line number for when the 'relativenumber' option is set, below the cursor line.
  ['CursorLineNr'] = { fg = c.orange },                            -- Like LineNr when 'cursorline' is set and 'cursorlineopt' contains "number" or is "both", for the cursor line.
  ['CursorLineFold'] = { link = 'CursorLineNr' },                  -- Like FoldColumn when 'cursorline' is set for the cursor line.
  ['CursorLineSign'] = { link = 'CursorLineNr' },                  -- Like SignColumn when 'cursorline' is set for the cursor line.
  ['MatchParen'] = { fg = c.gray_1, bg = c.chartreuse },           -- Character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
  ['ModeMsg'] = { fg = c.cyan },                                   -- 'showmode' message (e.g., "-- INSERT --").
  ['MsgArea'] = { fg = a.text },                                   -- Area for messages and command-line, see also 'cmdheight'.
  ['MsgSeparator'] = {},                                           -- Separator for scrolled messages |msgsep|.
  ['MoreMsg'] = {},                                                -- |more-prompt|
  ['NonText'] = {},                                                -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.

  ['Normal'] = { fg = a.text, bg = a.panel_bg },                   -- Normal text.
  ['NormalFloat'] = { fg = a.text, bg = a.popup_bg },              -- Normal text in floating windows.
  ['FloatBorder'] = { fg = 'NONE', bg = 'NONE' },                  -- Border of floating windows.
  ['FloatTitle'] = { fg = a.text, bold = true },                   -- Title of floating windows.
  ['FloatFooter'] = { fg = a.text, italic = true },                -- Footer of floating windows.
  ['NormalNC'] = { fg = a.text_no_focus, bg = a.panel_bg },        -- Normal text in non-current windows.

  -- Popup menus goes on top of floating windows
  ['Pmenu'] = { link = 'NormalFloat' },                -- Popup menu: Normal item.
  ['PmenuSel'] = { bg = a.current_place },             -- Popup menu: Selected item. Combined with |hl-Pmenu|.
  ['PmenuKind'] = { link = 'Pmenu' },                  -- Popup menu: Normal item "kind".
  ['PmenuKindSel'] = { link = 'PmenuSel' },            -- Popup menu: Selected item "kind".
  ['PmenuExtra'] = { link = 'Pmenu' },                 -- Popup menu: Normal item "extra text".
  ['PmenuExtraSel'] = { link = 'Pmenu' },              -- Popup menu: Selected item "extra text".
  ['PmenuSbar'] = { link = 'Pmenu' },                  -- Popup menu: Scrollbar.
  ['PmenuThumb'] = { bg = a.scrollbar },               -- Popup menu: Thumb of the scrollbar.
  ['PmenuMatch'] = { bg = a.selection },               -- Popup menu: Matched text in normal item. Combined with |hl-Pmenu|.
  ['PmenuMatchSel'] = { link = 'PmenuMatch' },         -- Popup menu: Matched text in selected item. Combined with |hl-PmenuMatch| and |hl-PmenuSel|.

  ['ComplMatchIns'] = { link = 'IncSearch' },          -- Matched text of the currently inserted completion.
  ['Question'] = {},                                   -- |hit-enter| prompt and yes/no questions. QuickFixLine Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
  ['Search'] = { link = 'IncSearch' },                 -- Last search pattern highlighting (see 'hlsearch'). Also used for similar items that need to stand out.
  ['SnippetTabstop'] = {},                             -- Tabstops in snippets. |vim.snippet|
  ['SpecialKey'] = {},                                 -- Unprintable characters: Text displayed differently from what it really is. But not 'listchars' whitespace. |hl-Whitespace|
  ['SpellBad'] = { fg = a.comment, undercurl = true }, -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
  ['SpellCap'] = { link = 'SpellBad' },                -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
  ['SpellLocal'] = { link = 'SpellBad' },              -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
  ['SpellRare'] = { link = 'SpellBad' },               -- Word that is recognized by the spellchecker as one that is hardly ever used. |spell| Combined with the highlighting used otherwise.

  ['StatusLine'] = { bg = a.panel_border_focus },      -- Status line of current window.
  ['StatusLineNC'] = { bg = c.panel_border },          -- Status lines of not-current windows.
  ['StatusLineTerm'] = { link = 'StatusLine' },        -- Status line of |terminal| window.
  ['StatusLineTermNC'] = { link = 'StatusLineNC' },    -- Status line of non-current |terminal| windows.
  ['TabLine'] = { link = 'StatusLineNC' },             -- Tab pages line, not active tab page label.
  ['TabLineFill'] = { bg = a.panel_bg },               -- Tab pages line, where there are no labels.
  ['TabLineSel'] = { link = 'StatusLine' },            -- Tab pages line, active tab page label.

  ['Title'] = {},                                      -- Titles for output from ":set all", ":autocmd" etc.
  ['Visual'] = { bg = a.selection },                   -- Visual mode selection.
  ['VisualNOS'] = { link = 'Visual' },                 -- Visual mode selection when vim is "Not Owning the Selection".
  ['WarningMsg'] = { fg = c.orange },                  -- Warning messages.
  ['Whitespace'] = {},                                 -- "nbsp", "space", "tab", "multispace", "lead" and "trail" in 'listchars'.
  ['WildMenu'] = { link = 'PmenuSel' },                -- Current match in 'wildmenu' completion.
  ['WinBar'] = { link = 'StatusLine' },                -- Window bar of current window.
  ['WinBarNC'] = { link = 'StatusLineNC' },            -- Window bar of not-current windows.

  -- FROM: https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance
  ['CmpItemAbbrDeprecated'] = { fg = a.comment, bg = 'NONE' },

  ['CmpItemAbbrMatch'] = { fg = a.selection, bg = 'NONE' },
  ['CmpItemAbbrMatchFuzzy'] = { link = 'CmpItemAbbrMatchFuzzy' },

  ['CmpItemKindVariable'] = { fg = a.constant, bg = 'NONE' },
  ['CmpItemKindInterface'] = { link = 'CmpItemKindVariable' },
  ['CmpItemKindText'] = { link = 'CmpItemKindVariable' },

  ['CmpItemKindFunction'] = { fg = a.fn, bg = 'NONE' },
  ['CmpItemKindMethod'] = { link = 'CmpItemKindFunction' },

  ['CmpItemKindKeyword'] = { fg = a.keyword, bg = 'NONE' },

  ['CmpItemKindProperty'] = { fg = a.label, bg = 'NONE' },
  ['CmpItemKindUnit'] = { link = 'CmpItemKindProperty' },

  -- FROM:
  -- The capture names, prefixed with `@`, are directly usable as highlight groups.
  -- For many commonly used captures, the corresponding highlight groups are linked
  -- to Nvim's standard |highlight-groups| by default (e.g., `@comment` links to
  -- `Comment`) but can be overridden in colorschemes.
  --
  -- A fallback system is implemented, so that more specific groups fallback to
  -- more generic ones. For instance, in a language that has separate doc comments
  -- (e.g., c, java, etc.), `@comment.documentation` could be used. If this group
  -- is not defined, the highlighting for an ordinary `@comment` is used. This way,
  -- existing color schemes already work out of the box, but it is possible to add
  -- more specific variants for queries that make them available.
  --
  -- As an additional rule, capture highlights can always be specialized by
  -- language, by appending the language name after an additional dot. For
  -- instance, to highlight comments differently per language: >vim
  --
  --     hi @comment.c guifg=Blue
  --     hi @comment.lua guifg=DarkBlue
  --     hi link @comment.documentation.java String
  --
  ['@variable'] = { fg = a.text },                         -- various variable names
  ['@variable.builtin'] = { fg = a.keyword },              -- built-in variable names (e.g. `this`, `self`)
  ['@variable.parameter'] = { fg = a.text },               -- parameters of a function
  ['@variable.parameter.builtin'] = { fg = a.comment },    -- special parameters (e.g. `_`, `it`)
  ['@variable.member'] = { fg = a.text },                  -- object and struct fields
  ['@constant'] = { fg = a.constant },                     -- constant identifiers
  ['@constant.builtin'] = { fg = a.constant },             -- built-in constant values
  ['@constant.macro'] = { fg = a.constant },               -- constants defined by the preprocessor
  ['@module'] = { fg = a.module },                         -- modules or namespaces
  ['@module.builtin'] = { fg = a.module },                 -- built-in modules or namespaces
  ['@label'] = { fg = a.label },                           -- `GOTO` and other labels (e.g. `label:` in C), including heredoc labels
  ['@string'] = { fg = a.string },                         -- string literals
  ['@string.documentation'] = {},                          -- string documenting code (e.g. Python docstrings)
  ['@string.regexp'] = { fg = a.regex },                   -- regular expressions
  ['@string.escape'] = {},                                 -- escape sequences
  ['@string.special'] = { link = 'Special' },              -- other special strings (e.g. dates)
  ['@string.special.symbol'] = { fg = a.label },           -- symbols or atoms
  ['@string.special.path'] = { fg = a.uri },               -- filenames
  ['@string.special.url'] = { fg = a.uri },                -- URIs (e.g. hyperlinks)
  ['@character'] = { fg = a.string },                      -- character literals
  ['@character.special'] = { fg = a.wildcard },            -- special characters (e.g. wildcards)
  ['@boolean'] = { fg = a.bool, bold = true },             -- boolean literals
  ['@number'] = { fg = a.number },                         -- numeric literals
  ['@number.float'] = { fg = a.number },                   -- floating-point number literals
  ['@type'] = { fg = a.type },                             -- type or class definitions and annotations
  ['@type.builtin'] = { fg = a.type },                     -- built-in types
  ['@type.definition'] = { fg = a.type },                  -- identifiers in type definitions (e.g. `typedef <type> <identifier>` in C)
  ['@attribute'] = { fg = a.meta_attribute },              -- attribute annotations (e.g. Python decorators, Rust lifetimes)
  ['@attribute.builtin'] = { fg = a.meta_attribute },      -- builtin annotations (e.g. `@property` in Python)
  ['@property'] = { fg = a.text },                         -- the key in key/value pairs
  ['@function'] = { fg = a.fn },                           -- function definitions
  ['@function.builtin'] = { fg = a.fn },                   -- built-in functions
  ['@function.call'] = { fg = a.fn },                      -- function calls
  ['@function.macro'] = { fg = a.fn },                     -- preprocessor macros
  ['@function.method'] = { fg = a.fn },                    -- method definitions
  ['@function.method.call'] = { fg = a.fn },               -- method calls
  ['@constructor'] = { fg = a.module },                    -- constructor calls and definitions
  ['@operator'] = { fg = a.operator },                     -- symbolic operators (e.g. `+`, `*`)
  ['@keyword'] = { fg = a.keyword },                       -- keywords not fitting into specific categories
  ['@keyword.coroutine'] = { fg = a.keyword },             -- keywords related to coroutines (e.g. `go` in Go, `async/await` in Python)
  ['@keyword.function'] = { fg = a.fn_def },               -- keywords that define a function (e.g. `func` in Go, `def` in Python)
  ['@keyword.operator'] = { fg = a.operator },             -- operators that are English words (e.g. `and`, `or`)
  ['@keyword.import'] = { fg = a.keyword },                -- keywords for including or exporting modules (e.g. `import`, `from` in Python)
  ['@keyword.type'] = { fg = a.type },                     -- keywords describing namespaces and composite types (e.g. `struct`, `enum`)
  ['@keyword.modifier'] = { fg = a.fn_def },               -- keywords modifying other constructs (e.g. `const`, `static`, `public`)
  ['@keyword.repeat'] = { fg = a.keyword },                -- keywords related to loops (e.g. `for`, `while`)
  ['@keyword.return'] = { fg = a.keyword },                -- keywords like `return` and `yield`
  ['@keyword.debug'] = { fg = a.keyword },                 -- keywords related to debugging
  ['@keyword.exception'] = { fg = a.keyword },             -- keywords related to exceptions (e.g. `throw`, `catch`)
  ['@keyword.conditional'] = { fg = a.keyword },           -- keywords related to conditionals (e.g. `if`, `else`)
  ['@keyword.conditional.ternary'] = { fg = a.keyword },   -- operator (e.g. `?`, `:`)
  ['@keyword.directive'] = { fg = a.fn_def },              -- various preprocessor directives and shebangs
  ['@keyword.directive.define'] = { fg = a.fn_def },       -- preprocessor definition directives
  ['@punctuation.delimiter'] = { fg = a.text },            -- delimiters (e.g. `;`, `.`, `,`)
  ['@punctuation.bracket'] = { fg = a.delimiter },         -- brackets (e.g. `()`, `{}`, `[]`)
  ['@punctuation.special'] = { fg = a.delimiter },         -- special symbols (e.g. `{}` in string interpolation)
  ['@comment'] = { fg = a.comment },                       -- line and block comments
  ['@comment.documentation'] = { fg = a.comment },         -- comments documenting code
  ['@comment.error'] = { fg = a.comment },                 -- error-type comments (e.g. `ERROR`, `FIXME`, `DEPRECATED`)
  ['@comment.warning'] = { fg = a.comment },               -- warning-type comments (e.g. `WARNING`, `FIX`, `HACK`)
  ['@comment.todo'] = { fg = a.comment },                  -- todo-type comments (e.g. `TODO`, `WIP`)
  ['@comment.note'] = { fg = a.comment },                  -- note-type comments (e.g. `NOTE`, `INFO`, `XXX`)
  ['@markup.strong'] = { bold = true },                    -- bold text
  ['@markup.italic'] = { italic = true },                  -- italic text
  ['@markup.strikethrough'] = { strikethrough = true },    -- struck-through text
  ['@markup.underline'] = { undercurl = true },            -- underlined text (only for literal underline markup!)
  ['@markup.heading'] = { bold = true },                   -- headings, titles (including markers)
  ['@markup.heading.0'] = { link = '@markup.heading' },    -- top-level heading
  ['@markup.heading.1'] = { link = '@markup.heading' },    -- section heading
  ['@markup.heading.2'] = { link = '@markup.heading' },    -- subsection heading
  ['@markup.heading.3'] = { link = '@markup.heading' },    -- and so on
  ['@markup.heading.4'] = { link = '@markup.heading' },    -- and so forth
  ['@markup.heading.5'] = { link = '@markup.heading' },    -- six levels ought to be enough for anybody
  ['@markup.quote'] = {},                                  -- block quotes
  ['@markup.math'] = {},                                   -- math environments (e.g. `$ ... $` in LaTeX)
  ['@markup.link'] = { link = '@string.special.url' },     -- text references, footnotes, citations, etc.
  ['@markup.link.label'] = {},                             -- link, reference descriptions
  ['@markup.link.url'] = { link = '@string.special.url' }, -- URL-style links
  ['@markup.raw'] = {},                                    -- literal or verbatim text (e.g. inline code)
  ['@markup.raw.block'] = {},                              -- literal or verbatim text as a stand-alone block
  ['@markup.list'] = {},                                   -- list markers
  ['@markup.list.checked'] = {},                           -- checked todo-style list markers
  ['@markup.list.unchecked'] = {},                         -- unchecked todo-style list markers
  ['@diff.plus'] = { link = 'DiffAdd' },                   -- added text (for diff files)
  ['@diff.minus'] = { link = 'DiffDelete' },               -- deleted text (for diff files)
  ['@diff.delta'] = { link = 'DiffChange' },               -- changed text (for diff files)
  ['@tag'] = {},                                           -- XML-style tag names (e.g. in XML, HTML, etc.)
  ['@tag.builtin'] = { fg = a.keyword },                   -- builtin tag names (e.g. HTML3 tags)
  ['@tag.attribute'] = { fg = a.text },                    -- XML-style tag attributes
  ['@tag.delimiter'] = { fg = a.delimiter },               -- XML-style tag delimiters

  -- The special `@spell` capture can be used to indicate that a node should be
  -- spell checked by Nvim's builtin |spell| checker. For example, the following
  -- capture marks comments as to be checked: >query

  ['@spell'] = {},

  -- Extra
  ['Special'] = { fg = a.text }, -- used by @markup.raw.block.markdown

  -- FROM: lsp-semantic-highlight
  -- The LSP client adds one or more highlights for each token. The highlight
  -- groups are derived from the token's type and modifiers:
  --   • `@lsp.type.<type>.<ft>` for the type
  --   • `@lsp.mod.<mod>.<ft>` for each modifier
  --   • `@lsp.typemod.<type>.<mod>.<ft>` for each modifier
  -- Use |:Inspect| to view the highlights for a specific token. Use |:hi| or
  -- |nvim_set_hl()| to change the appearance of semantic highlights: >vim
  --
  --     hi @lsp.type.function guifg=Yellow        " function names are yellow
  --     hi @lsp.type.variable.lua guifg=Green     " variables in lua are green
  --     hi @lsp.mod.deprecated gui=strikethrough  " deprecated is crossed out
  --     hi @lsp.typemod.function.async guifg=Blue " async functions are blue
  --
  -- The value |vim.hl.priorities|`.semantic_tokens` is the priority of the
  -- `@lsp.type.*` highlights. The `@lsp.mod.*` and `@lsp.typemod.*` highlights
  -- have priorities one and two higher, respectively.

  ['@lsp.type.class'] = { link = '@module' },                     -- Identifiers that declare or reference a class type
  ['@lsp.type.comment'] = { link = '@comment' },                  -- Tokens that represent a comment
  ['@lsp.type.decorator'] = { link = '@comment' },                -- Identifiers that declare or reference decorators and annotations
  ['@lsp.type.enum'] = { link = '@keyword.type' },                -- Identifiers that declare or reference an enumeration type
  ['@lsp.type.enumMember'] = { fg = a.text },                     -- Identifiers that declare or reference an enumeration property, constant, or member
  ['@lsp.type.event'] = { fg = a.text },                          -- Identifiers that declare an event property
  ['@lsp.type.function'] = { link = '@function' },                -- Identifiers that declare a function
  ['@lsp.type.interface'] = { link = '@function' },               -- Identifiers that declare or reference an interface type
  ['@lsp.type.keyword'] = { link = '@keyword' },                  -- Tokens that represent a language keyword
  ['@lsp.type.macro'] = { link = '@function.macro' },             -- Identifiers that declare a macro
  ['@lsp.type.method'] = { link = '@function.method' },           -- Identifiers that declare a member function or method
  ['@lsp.type.modifier'] = { link = '@keyword.modifier' },        -- Tokens that represent a modifier
  ['@lsp.type.namespace'] = { link = '@module' },                 -- Identifiers that declare or reference a namespace, module, or package
  ['@lsp.type.number'] = { link = '@number' },                    -- Tokens that represent a number literal
  ['@lsp.type.operator'] = { link = '@operator' },                -- Tokens that represent an operator
  ['@lsp.type.parameter'] = { fg = a.text },                      -- Identifiers that declare or reference a function or method parameters
  ['@lsp.type.property'] = { link = '@property' },                -- Identifiers that declare or reference a member property, member field, or member variable
  ['@lsp.type.regexp'] = { link = '@regexp' },                    -- Tokens that represent a regular expression literal
  ['@lsp.type.string'] = { link = '@string' },                    -- Tokens that represent a string literal
  ['@lsp.type.struct'] = { link = '@keyword.type' },              -- Identifiers that declare or reference a struct type
  ['@lsp.type.type'] = { link = '@keyword.type' },                -- Identifiers that declare or reference a type that is not covered above
  ['@lsp.type.typeParameter'] = { link = '@variable.parameter' }, -- Identifiers that declare or reference a type parameter
  ['@lsp.type.variable'] = { link = '@variable' },                -- Identifiers that declare or reference a local or global variable

  ['@lsp.mod.abstract'] = {},                                     -- Types and member functions that are abstract
  ['@lsp.mod.async'] = {},                                        -- Functions that are marked async
  ['@lsp.mod.declaration'] = {},                                  -- Declarations of symbols
  ['@lsp.mod.defaultLibrary'] = {},                               -- Symbols that are part of the standard library
  ['@lsp.mod.definition'] = {},                                   -- Definitions of symbols, for example, in header files
  ['@lsp.mod.deprecated'] = {},                                   -- Symbols that should no longer be used
  ['@lsp.mod.documentation'] = {},                                -- Occurrences of symbols in documentation
  ['@lsp.mod.modification'] = {},                                 -- Variable references where the variable is assigned to
  ['@lsp.mod.readonly'] = {},                                     -- Readonly variables and member fields (constants)
  ['@lsp.mod.static'] = {},                                       -- Class members (static members)
}

-- add highlights
for group, settings in pairs(groups) do
  -- ignore empty groups
  if next(settings) ~= nil then
    vim.api.nvim_set_hl(0, group, settings)
  end
end

-- i	Insert mode
-- r	Replace mode
-- v	Virtual Replace mode
local function statusline_color()
  local mode = vim.v.insertmode
  if mode == 'i' then
    vim.api.nvim_set_hl(0, 'statusline', { bg = c.blue, fg = c.gray_0 })
  elseif mode == 'r' then
    vim.api.nvim_set_hl(0, 'statusline', { bg = c.violet, fg = c.gray_0 })
  else
    vim.api.nvim_set_hl(0, 'statusline', { bg = c.red, fg = c.gray_0 })
  end
end

vim.api.nvim_create_autocmd('InsertEnter', { pattern = '*', callback = statusline_color })
vim.api.nvim_create_autocmd('InsertChange', { pattern = '*', callback = statusline_color })
vim.api.nvim_create_autocmd('InsertLeave',
  {
    pattern = '*',
    callback = function()
      vim.api.nvim_set_hl(0, 'statusline',
        { bg = a.panel_border_focus, fg = c.gray_0 })
    end
  })
