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

  _nvim-spelunk = prev.vimUtils.buildVimPlugin {
    pname = "spelunk.nvim";
    version = "git";
    src = prev.fetchFromGitHub {
      owner = "EvWilson";
      repo = "spelunk.nvim";
      rev = "553674609390156fb9d271f66fa501a1616e4052";
      sha256 = "sha256-x2XsEtA94EGzpkX3D9w6JpdPUAUJiyyI47El54Acwic=";
    };
    dependencies = [ final.vimPlugins.plenary-nvim ];
  };

  base_plugins = with final.vimPlugins; [
    # NAVIGATION
    (mkSelfPlugin "ranger")
    fzf-lua

    # LSP
    (mkSelfPlugin "lightbulb")

    # EXTRA
    (mkSelfPlugin "shade")
  ];

  full_plugins = with final.vimPlugins; [
    # THEME
    noice-nvim

    # LLM
    codecompanion-nvim

    # LSP
    aerial-nvim
    nvim-lspconfig # for Lsp* commands only
    #flutter-tools-nvim # sets up dartls + flutter utils

    # COMPLETION
    blink-cmp

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
    _nvim-spelunk
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
    markview-nvim
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

  # fix settings on nvim https://github.com/wgsl-analyzer/wgsl-analyzer/pull/549
  wgsl-analyzer = (prev.wgsl-analyzer.overrideAttrs (old: rec {
    version = "git";
    src = final.fetchFromGitHub {
      owner = "miguelklemmsilva";
      repo = "wgsl-analyzer";
      rev = "e3fb9dd701319e14bc785541f1eba3b9d4a6d164";
      hash = "sha256-9umFr8ry/qmSVz9rZ+Than45Ia2Tr7YQMaHNYhDQjTE=";
    };
    # replaces cargoHash
    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-uFiuC46j2uZc/+vPoU/2WJ06z3lqa+6AIQHMEBINkhs=";
    };
  }));
}
