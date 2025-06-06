final: prev:
let
  # NOTE: plugins should be with the path: /lua/$PLUGIN/init.lua
  # To test plugins locally use the following path: ~/.config/nvim/pack/$ANY/start/$PLUGIN/lua/$PLUGIN/init.lua

  _ranger = final.vimUtils.buildVimPlugin {
    pname = "ranger";
    version = "builtin";
    src = ./plugins/ranger;
    preInstall = ''
      mkdir -p $out/lua/ranger
    '';
    path = "lua/ranger";
    doCheck = false;
  };

  _shade = final.vimUtils.buildVimPlugin {
    pname = "shade";
    version = "builtin";
    src = ./plugins/shade;
    preInstall = ''
      mkdir -p $out/lua/shade
    '';
    path = "lua/shade";
    doCheck = false;
  };

  _nvim-macros = prev.vimUtils.buildVimPlugin {
    pname = "nvim-macros";
    version = "git";
    src = prev.fetchFromGitHub {
      owner = "shiryel";
      repo = "nvim-macros";
      rev = "f29d08ee7844ed6c9552699206e8c977d6936ee4";
      sha256 = "sha256-UDmMx4myoj0hx78C682BKMJ6RE0RQ/ilQatmMPGHtg8=";
    };
  };

  base_plugins = with final.vimPlugins; [
    # LSP
    nvim-lspconfig

    # NAVIGATION
    _ranger
    _shade
    fzf-lua
  ];

  full_plugins = with final.vimPlugins; [
    # THEME
    kanagawa-nvim

    # LLM
    codecompanion-nvim

    # LSP
    aerial-nvim
    #flutter-tools-nvim # sets up dartls + flutter utils

    # COMPLETION
    nvim-cmp
    cmp-nvim-lsp
    cmp-nvim-lsp-document-symbol # type of the symbol
    cmp-nvim-lsp-signature-help # params autocompletion
    cmp-nvim-lua # lua completion
    cmp-buffer
    cmp-path
    cmp_luasnip
    cmp-cmdline
    #cmp-omni
    #kotlin-vim
    #nvim-treesitter-textobjects

    # SNIPPET
    luasnip

    # DEBUGGER
    nvim-dap
    nvim-dap-ui

    # GIT
    neogit
    gitsigns-nvim
    diffview-nvim

    # NAVIGATION
    harpoon2
    nvim-web-devicons
    #nvim-tree-lua
    #telescope-nvim
    #telescope-fzf-native-nvim
    #telescope-file-browser-nvim

    # EXTRA
    tmux-nvim
    auto-session # alternative: persisted
    mini-nvim
    which-key-nvim
    ccc-nvim
    orgmode
    _nvim-macros
  ];
in
{
  # NOTE: we pin base plugins for stability and security reasons
  vimPlugins = prev.vimPlugins.extend (vfinal: vprev: {
    # overriding the existing fzf-lua breaks after some time
    fzf-lua = prev.vimUtils.buildVimPlugin {
      pname = "fzf-lua";
      version = "22-02-2025";
      src = prev.fetchFromGitHub {
        owner = "ibhagwan";
        repo = "fzf-lua";
        rev = "9b84b53f3297d4912d7eb95b979e9b27e2e61281";
        sha256 = "sha256-uNH+Sq5TxNIyleY7D17LRd1IPcO9K2WqWaD0A5FZbtw=";
      };
    };
  });

  # Fixes Neovide recompiling every update
  neovide = (prev.neovide.override { neovim = prev.neovim; });

  neovim-full = (prev.neovim.override {
    configure = {
      customRC = ''
        lua << EOF
          ${builtins.readFile ./base/configs.lua}
          ${builtins.readFile ./base/plugins.lua}
          ${builtins.readFile ./base/lsp.lua}
          ${builtins.readFile ./base/cmp.lua}
          ${builtins.readFile ./base/theme.lua}

          ${builtins.readFile ./full/dap.lua}
          ${builtins.readFile ./full/plugins.lua}
        EOF
      '';
      packages.myPlugins = {
        # loaded on launch
        start = base_plugins ++ full_plugins ++ [
          (final.vimPlugins.nvim-treesitter.withPlugins (_: final.vimPlugins.nvim-treesitter.allGrammars))
        ];
      };
    };
  });

  neovim = (prev.neovim.override {
    configure = {
      # will be passed to the -u option of nvim
      # do `cat .../bin/nvim` to find the `...-init.vim` (after -u) then
      # do a cat on it to see the file loading the plugins
      customRC = ''
        lua << EOF
          ${builtins.readFile ./base/configs.lua}
          ${builtins.readFile ./base/plugins.lua}
          ${builtins.readFile ./base/lsp.lua}
          ${builtins.readFile ./base/cmp.lua}
          ${builtins.readFile ./base/theme.lua}
        EOF
      '';
      # myPlugins can be any name
      packages.myPlugins = {
        # loaded on launch
        start = base_plugins ++ [
          #
          # SYNTAX HIGHLIGHT
          #
          # remove in nvim 0.10 ? (https://github.com/nvim-telescope/telescope.nvim/issues/2498)
          (final.vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
            # common
            tree-sitter-markdown
            tree-sitter-markdown-inline
            # languages
            tree-sitter-elixir
            tree-sitter-heex
            tree-sitter-nix
            tree-sitter-c
            tree-sitter-cpp
            tree-sitter-lua
            tree-sitter-yuck
            # web
            tree-sitter-javascript
            tree-sitter-html
            tree-sitter-css
            # tools
            tree-sitter-dot
            tree-sitter-cmake
            tree-sitter-make
            tree-sitter-dockerfile
            tree-sitter-yaml
            tree-sitter-toml
            tree-sitter-json
          ]))
        ];
        # manually loadable by calling `:packadd $plugin-name`
        opt = [ ];
      };
    };
  });
}
