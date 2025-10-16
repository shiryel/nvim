-- https://learn.microsoft.com/en-us/dotnet/api/microsoft.visualstudio.languageserver.protocol.servercapabilities

-- NOTE: some LSPs (like csharp-ls) say that they don't have some capabilities, but they do
-- so we don't check the following capabilities: documentFormattingProvider, hoverProvider

-- NOTE: (on v0.10)
-- Dynamic registration of LSP capabilities. An implication of this change is
-- that checking a client's `server_capabilities` is no longer a sufficient
-- indicator to see if a server supports a feature. Instead use
-- `client.supports_method(<method>)`. It considers both the dynamic
-- capabilities and static `server_capabilities`.

-- BIGFILE --
-- Prevents LSP and Treesitter attaching to the buffer

-- BASED ON https://github.com/folke/snacks.nvim/blob/main/lua/snacks/bigfile.lua (Apache 2.0)
local bigfile_size = 1.5 * 1024 * 1024 -- 1.5MB
local bigfile_line_length = 1000       -- useful for minified files
vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, buf)
        if not path or not buf or vim.bo[buf].filetype == "bigfile" then
          return
        end
        if path ~= vim.api.nvim_buf_get_name(buf) then
          return
        end
        local size = vim.fn.getfsize(path)
        if size <= 0 then
          return
        end
        if size > bigfile_size then
          return "bigfile"
        end
        local lines = vim.api.nvim_buf_line_count(buf)
        return (size - lines) / lines > bigfile_line_length and "bigfile" or nil
      end,
    },
  },
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = vim.api.nvim_create_augroup("bigfile", { clear = true }),
  pattern = "bigfile",
  callback = function(ev)
    vim.api.nvim_buf_call(ev.buf, function()
      if vim.fn.exists(":NoMatchParen") ~= 0 then
        vim.cmd([[NoMatchParen]])
      end
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(ev.buf) then
          vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ""
        end
      end)
    end)
  end
})

-- LSP --

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    local buf = ev.buf
    local fzf = require('fzf-lua')

    local function noremap(bind, command, desc)
      return vim.keymap.set("n", bind, command, { buffer = buf, silent = true, noremap = true, desc = desc })
    end

    local function voremap(bind, command, desc)
      return vim.keymap.set("v", bind, command, { buffer = buf, silent = true, noremap = true, desc = desc })
    end

    -----------------
    -- DIAGNOSTICS --
    -----------------

    -- :help vim.diagnostic.*
    local d = vim.diagnostic

    --noremap("<leader>qq", tb.diagnostics, "open diagnostics float window")
    noremap("<leader>dd", fzf.diagnostics_document, "open diagnostics float window")
    noremap("<leader>db", d.setloclist, "open diagnostics buffer")
    noremap("<leader>ds", d.show, "show diagnostics")
    noremap("<leader>dh", d.hide, "hide diagnostics")
    noremap("<leader>dn", d.get_next, "get next diagnostic")
    noremap("<leader>dp", d.get_prev, "get previous diagnostic")

    ---------------
    -- FORMATING --
    ---------------

    -- :help vim.lsp.*
    local b = vim.lsp.buf

    -- Formats the current buffer
    noremap("<c-f>", b.format, "format")
    voremap("<c-f>", b.format, "format") -- range format is configured automatically when bound to visual mode

    ----------
    -- GOTO --
    ----------
    if client:supports_method('textDocument/definition') then
      noremap("gd", b.definition, "go to definition")
    end

    -- Jumps to the declaration of the symbol under the cursor (less used by LSPs)
    if client:supports_method('textDocument/declaration') then
      noremap("gD", b.declaration, "go to declaration")
    end

    --if client:supports_method('textDocument/typeDefinition') then
    --  noremap("gt", b.type_definition, "go to type definition")
    --end

    ----------------
    -- COMPLETION --
    ----------------
    --if client:supports_method('textDocument/completion') then
    --  vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
    --end
    ---- Enable completion triggered by <c-x><c-o>
    --vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = buf })

    ---------------
    -- LOCATIONS --
    ---------------
    -- see: https://github.com/ibhagwan/fzf-lua/issues/669
    noremap("ga", fzf.lsp_finder, "list any LSP location (combined view)")

    -- Lists all the references to the symbol under the cursor in the quickfix window
    if client:supports_method('textDocument/references') then
      noremap("<leader>r", fzf.lsp_references, "list references to symbol")
    end

    -- Lists all the implementations for the symbol under the cursor in the
    -- quickfix window
    if client:supports_method('textDocument/implementation') then
      noremap("<leader>i", fzf.lsp_implementations, "list symbol's implementations")
    end

    -------------
    -- HELPERS --
    -------------
    vim.lsp.inlay_hint.enable(true)
    -- Displays hover information about the symbol under the cursor in a floating
    -- window. Calling the function twice will jump into the floating window
    if client:supports_method('textDocument/hover') then
      noremap("<leader>h", b.hover, "show symbol info")
    end

    -- Displays signature information about the symbol under the cursor in a
    -- floating window
    if client:supports_method('textDocument/signatureHelp') then
      noremap("<leader>H", b.signature_help, "show symbol signature")
    end

    -------------
    -- ACTIONS --
    -------------

    -- Renames all references to the symbol under the cursor
    if client:supports_method('textDocument/rename') then
      noremap("<leader>r", b.rename, "rename all references")
    end

    if client:supports_method('textDocument/codeAction') then
      noremap("<leader>?", fzf.lsp_code_actions, "Code actions")
    end

    ---------------
    -- HIGHLIGHT --
    ---------------
    -- Send request to the server to resolve document highlights for the current
    -- text document position. This request can be triggered by a key mapping or
    -- by events such as `CursorHold`, e.g.:
    --   autocmd CursorHold  <buffer> lua b.document_highlight()
    --   autocmd CursorHoldI <buffer> lua b.document_highlight()
    --   autocmd CursorMoved <buffer> lua b.clear_references()
    --
    -- Note: Usage of |b.document_highlight()| requires the following
    -- highlight groups to be defined or you won't be able to see the actual
    -- highlights: hl-LspReferenceText, hl-LspReferenceRead, hl-LspReferenceWrite
    if client:supports_method('textDocument/documentHighlight') then
      vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
      vim.api.nvim_clear_autocmds { buffer = buf, group = "lsp_document_highlight" }
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = b.document_highlight,
        buffer = buf,
        group = "lsp_document_highlight",
        desc = "Document Highlight",
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        callback = b.clear_references,
        buffer = buf,
        group = "lsp_document_highlight",
        desc = "Clear All the References",
      })
    end

    -----------------
    -- WORKSPACES --
    -----------------

    -- Add the folder at path to the workspace folders. If {path} is not
    -- provided, the user will be prompted for a path using |input()|
    --if cap.foldingRangeProvider then
    if client:supports_method('workspace/willCreateFiles') then
      noremap("<leader>wa", b.add_workspace_folder, "add workspace folder")
    end
    if client:supports_method('workspace/willDeleteFiles') then
      noremap("<leader>wd", b.remove_workspace_folder, "remove workspace folder")
    end
    if client:supports_method('workspace/workspaceFolders') then
      noremap("<leader>wl", b.list_workspace_folders, "list workspace folders")
    end
    -- Lists all symbols in the current workspace in the quickfix window.
    -- The list is filtered against {query}; if the argument is omitted from the
    -- call, the user is prompted to enter a string on the command line. An empty
    -- string means no filtering is done
    if client:supports_method('workspace/symbol') then
      noremap("<leader>ws", b.workspace_symbol, "list symbols on workspace")
    end
  end,
})

-----------
-- UTILS --
-----------
-- from: https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/util.lua

local function root_pattern(...)
  local patterns = M.tbl_flatten { ... }
  return function(startpath)
    startpath = M.strip_archive_subpath(startpath)
    for _, pattern in ipairs(patterns) do
      local match = M.search_ancestors(startpath, function(path)
        for _, p in ipairs(vim.fn.glob(table.concat({ escape_wildcards(path), pattern }, '/'), true, true)) do
          if vim.loop.fs_stat(p) then
            return path
          end
        end
      end)

      if match ~= nil then
        return match
      end
    end
  end
end

local function find_git_ancestor(startpath)
  return vim.fs.dirname(vim.fs.find('.git', { path = startpath, upward = true })[1])
end

----------------
-- LSP CONFIG --
----------------

-- Get additional info when using cmp-nvim
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, blink = pcall(require, 'blink.cmp')
if ok then
  capabilities = blink.get_lsp_capabilities()
end

vim.lsp.config('*', {
  root_markers = { '.git' },
  capabilities = capabilities
})

-- ELIXIR
vim.lsp.config.elixirls = {
  cmd = { "elixir-ls" },
  filetypes = { 'elixir', 'eelixir', 'heex', 'surface' },
  root_dir = function(bufnr, cb)
    local fname = vim.api.nvim_buf_get_name(bufnr)

    local matches = vim.fs.find({ 'mix.exs' }, { upward = true, limit = 2, path = fname })
    local child_or_root_path, maybe_umbrella_path = unpack(matches)
    local root_dir = vim.fs.dirname(maybe_umbrella_path or child_or_root_path)
    cb(root_dir)
  end,
}

-- TAILWIND
vim.lsp.config.tailwindcss = {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    -- html
    'aspnetcorerazor',
    'astro',
    'astro-markdown',
    'blade',
    'clojure',
    'django-html',
    'htmldjango',
    'edge',
    'eelixir', -- vim ft
    'elixir',
    'ejs',
    'erb',
    'eruby', -- vim ft
    'gohtml',
    'gohtmltmpl',
    'haml',
    'handlebars',
    'hbs',
    'html',
    'htmlangular',
    'html-eex',
    'heex',
    'jade',
    'leaf',
    'liquid',
    'markdown',
    'mdx',
    'mustache',
    'njk',
    'nunjucks',
    'php',
    'razor',
    'slim',
    'twig',
    -- css
    'css',
    'less',
    'postcss',
    'sass',
    'scss',
    'stylus',
    'sugarss',
    -- js
    'javascript',
    'javascriptreact',
    'reason',
    'rescript',
    'typescript',
    'typescriptreact',
    -- mixed
    'vue',
    'svelte',
    'templ',
    'rust',
  },
  root_markers = {
    "mix.exs",
    "tailwind.config.js",
    "tailwind.config.ts",
    "postcss.config.js",
    "postcss.config.ts",
    "package.json",
    "node_modules",
    ".git"
  },
  settings = {
    tailwindCSS = {
      colorDecorators = false, -- kinda buggy
      validate = true,
      lint = {
        cssConflict = 'warning',
        invalidApply = 'error',
        invalidScreen = 'error',
        invalidVariant = 'error',
        invalidConfigPath = 'error',
        invalidTailwindDirective = 'error',
        recommendedVariantOrder = 'warning',
      },
      classAttributes = {
        'class',
        'className',
        'class:list',
        'classList',
        'ngClass',
      },
      includeLanguages = {
        elixir = "html-eex",
        eelixir = 'html-eex',
        heex = "html-eex",
        rust = "html", -- for Dioxus
        eruby = 'erb',
        templ = 'html',
        htmlangular = 'html',
      },
      experimental = {
        classRegex = {
          'class[:]\\s*"([^"]*)"',
        },
      },
    },
  },
}

-- GDSCRIPT
local gdscript_port = os.getenv 'GDScript_Port' or '6005'
vim.lsp.config.gdscript = {
  cmd = vim.lsp.rpc.connect('127.0.0.1', tonumber(gdscript_port)),
  filetypes = { 'gd', 'gdscript', 'gdscript3' },
  root_markers = { 'project.godot' },
}

-- GDSCRIPT formater (EFM)
vim.lsp.config.efm = {
  cmd = { "efm-langserver" },
  filetypes = { 'gd', 'gdscript', 'gdscript3' },
  root_markers = { 'project.godot' },
  settings = {
    rootMarkers = { "project.godot", ".git/" },
    lintDebounce = 100,
    languages = {
      gdscript = {
        formatCommand = "gdformat -l 100",
        formatStdin = true
      }
    }
  },
}

-- LUA
vim.lsp.config.lua_ls = {
  cmd = { "lua-language-server" },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.luarc.jsonc',
    '.luacheckrc',
    '.stylua.toml',
    'stylua.toml',
    'selene.toml',
    'selene.yml',
  },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" }
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
        }
      },
      telemetry = {
        enable = false
      }
    }
  }
}

-- NIX
vim.lsp.config.nil_ls = {
  cmd = { "nil" },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix' },
  settings = {
    ['nil'] = {
      formatting = {
        command = { "nixpkgs-fmt" }
      },
      nix = {
        flake = {
          autoEvalInputs = true
        },
        maxMemoryMB = 4096
      }
    }
  }
}

-- C (CLANG)
vim.lsp.config.clangd = {
  cmd = { 'clangd', '--background-index' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
  root_markers = {
    '.clangd',
    '.clang-tidy',
    '.clang-format',
    'compile_commands.json',
    'compile_flags.txt',
    'configure.ac' -- AutoTools
  },
}

-- RUST
vim.lsp.config.rust_analyzer = {
  cmd = { "rust-analyzer" },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml' },
  -- https://github.com/rust-lang/rust-analyzer/blob/master/docs/user/generated_config.adoc
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = true,
      completion = {
        privateEditable = {
          enable = true
        },
        termSearch = {
          enable = true
        }
      },
      inlayHints = {
        lifetimeElisionHint = {
          enable = "skip_trivial"
        }
      },
      diagnostics = {
        styleLints = {
          enable = true,
        }
      },
      check = {
        ignore = { "dead_code" },
      },
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
      cargo = {
        features = "all",
        buildScripts = {
          enable = true,
        },
      },
      procMacro = {
        enable = true
      },
    }
  },
}

-- WGSL / WESL
vim.lsp.config.wgsl_analyzer = {
  cmd = { "wgsl-analyzer" },
  filetypes = { 'wgsl', 'wesl' },
  root_markers = { '.git' },
  -- https://github.com/wgsl-analyzer/wgsl-analyzer/blob/main/editors/code/package.json
  settings = {
    ["wgsl-analyzer"] = {
      diagnostics = {
        typeErrors = false, -- crashes the LSP when using customImports
        -- TODO: wait for support
        nagaParsingErrors = true,
        nagaValidationErrors = true,
      },
      -- GENERATED WITH
      -- rg define_import_path -g '*.wgsl' --sort path | sd '^([^:]*):#define_import_path (.*)' ' ["$2"] = "file:///home/shiryel/code/bevy/$1",' >> wgsl_paths.txt
      customImports = {
        ["bevy_core_pipeline::fullscreen_vertex_shader"] =
        "file:///home/shiryel/code/bevy/crates/bevy_core_pipeline/src/fullscreen_vertex_shader/fullscreen.wgsl",
        ["bevy_core_pipeline::oit"] = "file:///home/shiryel/code/bevy/crates/bevy_core_pipeline/src/oit/oit_draw.wgsl",
        ["bevy_core_pipeline::tonemapping_lut_bindings"] =
        "file:///home/shiryel/code/bevy/crates/bevy_core_pipeline/src/tonemapping/lut_bindings.wgsl",
        ["bevy_core_pipeline::tonemapping"] =
        "file:///home/shiryel/code/bevy/crates/bevy_core_pipeline/src/tonemapping/tonemapping_shared.wgsl",
        ["bevy_pbr::atmosphere::bindings"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/atmosphere/bindings.wgsl",
        ["bevy_pbr::atmosphere::bruneton_functions"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/atmosphere/bruneton_functions.wgsl",
        ["bevy_pbr::atmosphere::functions"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/atmosphere/functions.wgsl",
        ["bevy_pbr::atmosphere::types"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/atmosphere/types.wgsl",
        ["bevy_pbr::decal::clustered"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/decal/clustered.wgsl",
        ["bevy_pbr::decal::forward"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/decal/forward_decal.wgsl",
        ["bevy_pbr::pbr_deferred_functions"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/deferred/pbr_deferred_functions.wgsl",
        ["bevy_pbr::pbr_deferred_types"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/deferred/pbr_deferred_types.wgsl",
        ["bevy_pbr::environment_map"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/light_probe/environment_map.wgsl",
        ["bevy_pbr::irradiance_volume"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/light_probe/irradiance_volume.wgsl",
        ["bevy_pbr::light_probe"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/light_probe/light_probe.wgsl",
        ["bevy_pbr::lightmap"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/lightmap/lightmap.wgsl",
        ["bevy_pbr::meshlet_bindings"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/meshlet/meshlet_bindings.wgsl",
        ["bevy_pbr::meshlet_cull_shared"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/meshlet/meshlet_cull_shared.wgsl",
        ["bevy_pbr::meshlet_visibility_buffer_resolve"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/meshlet/visibility_buffer_resolve.wgsl",
        ["bevy_pbr::prepass_bindings"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/prepass/prepass_bindings.wgsl",
        ["bevy_pbr::prepass_io"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/prepass/prepass_io.wgsl",
        ["bevy_pbr::prepass_utils"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/prepass/prepass_utils.wgsl",
        ["bevy_pbr::clustered_forward"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/clustered_forward.wgsl",
        ["bevy_pbr::fog"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/fog.wgsl",
        ["bevy_pbr::forward_io"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/forward_io.wgsl",
        ["bevy_pbr::mesh_bindings"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/mesh_bindings.wgsl",
        ["bevy_pbr::mesh_functions"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/mesh_functions.wgsl",
        ["bevy_pbr::mesh_types"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/mesh_types.wgsl",
        ["bevy_pbr::mesh_view_bindings"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/mesh_view_bindings.wgsl",
        ["bevy_pbr::mesh_view_types"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/mesh_view_types.wgsl",
        ["bevy_pbr::morph"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/morph.wgsl",
        ["bevy_pbr::occlusion_culling"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/occlusion_culling.wgsl",
        ["bevy_pbr::parallax_mapping"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/parallax_mapping.wgsl",
        ["bevy_pbr::ambient"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/pbr_ambient.wgsl",
        ["bevy_pbr::pbr_bindings"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/pbr_bindings.wgsl",
        ["bevy_pbr::pbr_fragment"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/pbr_fragment.wgsl",
        ["bevy_pbr::pbr_functions"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/pbr_functions.wgsl",
        ["bevy_pbr::lighting"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/pbr_lighting.wgsl",
        ["bevy_pbr::pbr_prepass_functions"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/pbr_prepass_functions.wgsl",
        ["bevy_pbr::transmission"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/pbr_transmission.wgsl",
        ["bevy_pbr::pbr_types"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/pbr_types.wgsl",
        ["bevy_pbr::rgb9e5"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/rgb9e5.wgsl",
        ["bevy_pbr::shadow_sampling"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/shadow_sampling.wgsl",
        ["bevy_pbr::shadows"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/shadows.wgsl",
        ["bevy_pbr::skinning"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/skinning.wgsl",
        ["bevy_pbr::utils"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/utils.wgsl",
        ["bevy_pbr::view_transformations"] =
        "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/render/view_transformations.wgsl",
        ["bevy_pbr::ssao_utils"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/ssao/ssao_utils.wgsl",
        ["bevy_pbr::raymarch"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/ssr/raymarch.wgsl",
        ["bevy_pbr::ssr"] = "file:///home/shiryel/code/bevy/crates/bevy_pbr/src/ssr/ssr.wgsl",
        ["bevy_core_pipeline::post_processing::chromatic_aberration"] =
        "file:///home/shiryel/code/bevy/crates/bevy_post_process/src/effect_stack/chromatic_aberration.wgsl",
        ["bevy_render::bindless"] = "file:///home/shiryel/code/bevy/crates/bevy_render/src/bindless.wgsl",
        ["bevy_render::color_operations"] = "file:///home/shiryel/code/bevy/crates/bevy_render/src/color_operations.wgsl",
        ["bevy_pbr::mesh_preprocess_types"] =
        "file:///home/shiryel/code/bevy/crates/bevy_render/src/experimental/occlusion_culling/mesh_preprocess_types.wgsl",
        ["bevy_render::globals"] = "file:///home/shiryel/code/bevy/crates/bevy_render/src/globals.wgsl",
        ["bevy_render::maths"] = "file:///home/shiryel/code/bevy/crates/bevy_render/src/maths.wgsl",
        ["bevy_render::view"] = "file:///home/shiryel/code/bevy/crates/bevy_render/src/view/view.wgsl",
        ["bevy_solari::gbuffer_utils"] =
        "file:///home/shiryel/code/bevy/crates/bevy_solari/src/realtime/gbuffer_utils.wgsl",
        ["bevy_solari::presample_light_tiles"] =
        "file:///home/shiryel/code/bevy/crates/bevy_solari/src/realtime/presample_light_tiles.wgsl",
        ["bevy_solari::world_cache"] =
        "file:///home/shiryel/code/bevy/crates/bevy_solari/src/realtime/world_cache_query.wgsl",
        ["bevy_solari::brdf"] = "file:///home/shiryel/code/bevy/crates/bevy_solari/src/scene/brdf.wgsl",
        ["bevy_solari::scene_bindings"] =
        "file:///home/shiryel/code/bevy/crates/bevy_solari/src/scene/raytracing_scene_bindings.wgsl",
        ["bevy_solari::sampling"] = "file:///home/shiryel/code/bevy/crates/bevy_solari/src/scene/sampling.wgsl",
        ["bevy_sprite::mesh2d_bindings"] =
        "file:///home/shiryel/code/bevy/crates/bevy_sprite_render/src/mesh2d/mesh2d_bindings.wgsl",
        ["bevy_sprite::mesh2d_functions"] =
        "file:///home/shiryel/code/bevy/crates/bevy_sprite_render/src/mesh2d/mesh2d_functions.wgsl",
        ["bevy_sprite::mesh2d_types"] =
        "file:///home/shiryel/code/bevy/crates/bevy_sprite_render/src/mesh2d/mesh2d_types.wgsl",
        ["bevy_sprite::mesh2d_vertex_output"] =
        "file:///home/shiryel/code/bevy/crates/bevy_sprite_render/src/mesh2d/mesh2d_vertex_output.wgsl",
        ["bevy_sprite::mesh2d_view_bindings"] =
        "file:///home/shiryel/code/bevy/crates/bevy_sprite_render/src/mesh2d/mesh2d_view_bindings.wgsl",
        ["bevy_sprite::mesh2d_view_types"] =
        "file:///home/shiryel/code/bevy/crates/bevy_sprite_render/src/mesh2d/mesh2d_view_types.wgsl",
        ["bevy_sprite::sprite_view_bindings"] =
        "file:///home/shiryel/code/bevy/crates/bevy_sprite_render/src/render/sprite_view_bindings.wgsl",
        ["bevy_ui::ui_node"] = "file:///home/shiryel/code/bevy/crates/bevy_ui_render/src/ui.wgsl",
        ["bevy_ui::ui_vertex_output"] = "file:///home/shiryel/code/bevy/crates/bevy_ui_render/src/ui_vertex_output.wgsl",
      },
      inlayHints = {
        enabled = true,
        typeHints = true,
        parameterHints = true,
        structLayoutHints = true,
        typeVerbosity = "full"
      }
    }
  }
}

-- JS
vim.lsp.config.eslint = {
  cmd = { 'vscode-eslint-language-server', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'vue',
    'svelte',
    'astro',
  },
  root_markers = {
    '.eslintrc',
    '.eslintrc.js',
    '.eslintrc.cjs',
    '.eslintrc.yaml',
    '.eslintrc.yml',
    '.eslintrc.json',
    'eslint.config.js',
    'eslint.config.mjs',
    'eslint.config.cjs',
    'eslint.config.ts',
    'eslint.config.mts',
    'eslint.config.cts',
  },
  -- https://github.com/Microsoft/vscode-eslint#settings-options
  settings = {
    validate = 'on',
    packageManager = nil,
    useESLintClass = false,
    experimental = {
      useFlatConfig = false,
    },
    codeActionOnSave = {
      enable = false,
      mode = 'all',
    },
    format = true,
    quiet = false,
    onIgnoredFiles = 'off',
    rulesCustomizations = {},
    run = 'onType',
    problems = {
      shortenToSingleLine = false,
    },
    -- nodePath configures the directory in which the eslint server should start its node_modules resolution.
    -- This path is relative to the workspace folder (root dir) of the server instance.
    nodePath = '',
    -- use the workspace folder location or the file location (if no workspace folder is open) as the working directory
    workingDirectory = { mode = 'location' },
    codeAction = {
      disableRuleComment = {
        enable = true,
        location = 'separateLine',
      },
      showDocumentation = {
        enable = true,
      },
    },
  },
}

-- SVELTE
vim.lsp.config.svelte = {
  cmd = { 'svelteserver', '--stdio' },
  filetypes = { 'svelte' },
  root_markers = { 'package.json' },
}

-- TYPST
vim.lsp.config.tinymist = {
  cmd = { 'tinymist' },
  filetypes = { 'typst' },
  --root_dir = function(fname)
  --  return lsp_util.root_pattern '.git' (fname) or lsp_util.path.dirname(fname)
  --end
}

-- TERRAFORM
vim.lsp.config.terraformls = {
  cmd = { 'terraform-ls', 'serve' },
  filetypes = { 'terraform', 'terraform-vars' },
  root_markers = { '.terraform' },
}

-- DART
-- NOTE: May need the command `dart pub get` to work correctly
vim.lsp.config.dartls = {
  cmd = { 'dart', 'language-server', '--protocol=lsp' },
  filetypes = { 'dart' },
  root_markers = { 'pubspec.yaml' },
  init_options = {
    onlyAnalyzeProjectsWithOpenFiles = true,
    suggestFromUnimportedLibraries = true,
    closingLabels = true,
    outline = true,
    flutterOutline = true,
  },
  settings = {
    dart = {
      completeFunctionCalls = true,
      showTodos = true,
    },
  },
}

-- defaults to works as if `single_file_support = true`
-- see: https://github.com/neovim/neovim/issues/31762
vim.lsp.enable({
  'elixirls',
  'tailwindcss',
  'gdscript',
  'efm',
  'lua_ls',
  'nil_ls',
  'clangd',
  'rust_analyzer',
  'wgsl_analyzer',
  'eslint',
  'svelte',
  'tinymist',
  'terraformls',
  --'dartls',
})
