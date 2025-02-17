final: prev:

let
  base_plugins = with final.vimPlugins; [
    # THEME
    kanagawa-nvim

    # LSP
    nvim-lspconfig

    # NAVIGATION
    nvim-tree-lua
    fzf-lua
    #plenary-nvim
    #telescope-nvim
    #telescope-fzf-native-nvim
  ];

  full_plugins = with final.vimPlugins; [
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
    gitsigns-nvim
    diffview-nvim

    # NAVIGATION
    harpoon2
    nvim-web-devicons

    # EXTRA
    mini-nvim
    which-key-nvim
    ccc-nvim
    focus-nvim
  ];
in
{
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

          ${builtins.readFile ./full/dap.lua}
          ${builtins.readFile ./full/plugins.lua}
        EOF
      '';
      #${builtins.readFile ./full/cmp.lua}
      packages.myPlugins = {
        # loaded on launch
        start = base_plugins ++ full_plugins ++ [
          (final.vimPlugins.nvim-treesitter.withPlugins (_: final.tree-sitter.allGrammars))
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
