final: prev:
let
  _ranger = final.vimUtils.buildVimPlugin {
    pname = "ranger";
    version = "builtin";
    src = ./plugins/ranger;
    doCheck = false;
  };



  base_plugins = with final.vimPlugins; [
    # THEME
    kanagawa-nvim

    # LSP
    nvim-lspconfig

    # NAVIGATION
    _ranger
    fzf-lua

    #plenary-nvim
    #telescope-nvim
    #telescope-fzf-native-nvim
    #telescope-file-browser-nvim
  ];

  full_plugins = with final.vimPlugins; [
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
    #nvim-tree-lua
    harpoon2
    nvim-web-devicons

    # EXTRA
    persisted-nvim
    mini-nvim
    which-key-nvim
    ccc-nvim
    focus-nvim
  ];
in
{
  # NOTE: we pin base plugins for stability and security reasons
  vimPlugins = prev.vimPlugins.extend (vfinal: vprev: {
    fzf-lua = vprev.fzf-lua.overrideAttrs (old: rec {
      version = "22-02-2025";
      src = prev.fetchFromGitHub {
        owner = "ibhagwan";
        repo = "fzf-lua";
        rev = "9b84b53f3297d4912d7eb95b979e9b27e2e61281";
        sha256 = "sha256-uNH+Sq5TxNIyleY7D17LRd1IPcO9K2WqWaD0A5FZbtw=";
      };
    });

    # https://github.com/nvim-lua/plenary.nvim
    plenary-nvim = vprev.plenary-nvim.overrideAttrs (old: rec {
      version = "11-02-2025";
      src = prev.fetchFromGitHub {
        owner = "nvim-lua";
        repo = "plenary.nvim";
        rev = "857c5ac632080dba10aae49dba902ce3abf91b35";
        sha256 = "sha256-8FV5RjF7QbDmQOQynpK7uRKONKbPRYbOPugf9ZxNvUs=";
      };
    });

    # https://github.com/nvim-telescope/telescope.nvim
    telescope-nvim = vprev.telescope-nvim.overrideAttrs (old: rec {
      version = "11-02-2025";
      src = prev.fetchFromGitHub {
        owner = "nvim-telescope";
        repo = "telescope.nvim";
        rev = "78857db9e8d819d3cc1a9a7bdc1d39d127a36495";
        sha256 = "sha256-zeyZMh5exWSK8tERzPF/qE24qpaVek7G4sO/yprXYqM=";
      };
    });

    telescope-fzf-native-nvim = vprev.telescope-fzf-native-nvim.overrideAttrs (old: {
      version = "11-02-2025";
      src = prev.fetchFromGitHub {
        owner = "nvim-telescope";
        repo = "telescope-fzf-native.nvim";
        rev = "2a5ceff981501cff8f46871d5402cd3378a8ab6a";
        sha256 = "sha256-0dGvpN8Vn+aU6j8N0tTD8AOzOAHGemlPAcLKyqlWvlg=";
      };
    });

    telescope-file-browser-nvim = vprev.telescope-file-browser-nvim.overrideAttrs (old: {
      version = "24-10-2024";
      src = prev.fetchFromGitHub {
        owner = "nvim-telescope";
        repo = "telescope-file-browser.nvim";
        rev = "626998e5c1b71c130d8bc6cf7abb6709b98287bb";
        sha256 = "sha256-VJbRi91TTOwUkQYyTM6Njl7MtX8/mOjINiqWYWEtyxg=";
      };
    });
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
