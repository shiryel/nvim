final: prev:
let
  # NOTE: plugins should be with the path: /lua/$PLUGIN/init.lua
  # To test plugins locally use the following path: ~/.config/nvim/pack/$ANY/start/$PLUGIN/lua/$PLUGIN/init.lua

  mkSelfPlugin = name: final.vimUtils.buildVimPlugin {
    pname = name;
    version = "builtin";
    src = ./plugins/${name};
    preInstall = ''
      mkdir -p $out/lua/${name}
    '';
    path = "lua/${name}";
    doCheck = false;
  };

  _ranger = mkSelfPlugin "ranger";
  _shade = mkSelfPlugin "shade";
  _lightbulb = mkSelfPlugin "lightbulb";

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

  _nvim-lsp-endhints = prev.vimUtils.buildVimPlugin {
    pname = "nvim-lsp-endhints";
    version = "git";
    src = prev.fetchFromGitHub {
      owner = "chrisgrieser";
      repo = "nvim-lsp-endhints";
      rev = "7917c7af1ec345ca9b33e8dbcd3723fc15d023c0";
      sha256 = "sha256-ZssCVWm7/4U7oAsEXB1JgLoSzcdAjXsO2wEDyS40/SQ=";
    };
  };

  base_plugins = with final.vimPlugins; [
    # NAVIGATION
    _ranger
    fzf-lua

    # LSP
    _lightbulb

    # EXTRA
    _shade
  ];

  full_plugins = with final.vimPlugins; [
    # THEME
    noice-nvim

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
    _nvim-lsp-endhints
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
          ${builtins.readFile ./base/theme.lua}
          ${builtins.readFile ./base/configs.lua}
          ${builtins.readFile ./base/plugins.lua}
          ${builtins.readFile ./base/lsp.lua}

          ${builtins.readFile ./full/cmp.lua}
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
          ${builtins.readFile ./base/theme.lua}
          ${builtins.readFile ./base/configs.lua}
          ${builtins.readFile ./base/plugins.lua}
          ${builtins.readFile ./base/lsp.lua}
          ${builtins.readFile ./base/cmp.lua}
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
