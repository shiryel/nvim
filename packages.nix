{ pkgs, ... }:

{
  # neovim config is on /overlays/overrides/neovim

  environment.variables = {
    NEOVIDE_MULTIGRID = "1";
    EDITOR = "vim";
    VISUAL = "vim";
  };

  # Snippets based on: https://github.com/rafamadriz/friendly-snippets
  environment.etc."nvim/snippets/elixir.json".source = ./snippets/elixir.json;
  environment.etc."nvim/snippets/eelixir.json".source = ./snippets/eelixir.json;
  environment.etc."nvim/snippets/tailwind.json".source = ./snippets/tailwind.json;
  environment.etc."nvim/snippets/package.json".source = ./snippets/package.json;

  # last update: c0f1306db5814e0df76cd942ae59b03e43ea0493
  environment.etc."nvim/snippets/temple.json".source = ./snippets/temple.json;

  environment.systemPackages = with pkgs; [
    ranger

    # Syntax Highlight
    tree-sitter
    # for fzf-vim
    bat
    delta

    # Finders
    fzf # (fzf-vim)
    perl # (fzf-vim)
    silver-searcher
    ripgrep

    # Language servers
    efm-langserver # General Purpose LSP
    elixir-ls # Elixir
    tailwindcss-language-server # TailwindCSS
    #nixd # Nix
    nil # Nix
    #ccls # GCC
    zls # Zig
    rust-analyzer # Rust
    wgsl-analyzer # WGSL / WESL
    #python39Packages.gdtoolkit # GDScript
    #python310Packages.python-lsp-server # pylsp
    nodePackages.svelte-language-server
    vscode-langservers-extracted # JS
    tinymist # typst lsp
    lua-language-server
    terraform-ls

    # Formatters
    nixpkgs-fmt # Nix
    rustfmt # Rust

    gcc
  ];
}
