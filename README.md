# Nixos Neovim Config

Configure with:
```nix
{
  inputs = {
    neovim.url = "github:shiryel/nvim/master";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.default =
      nixpkgs.lib.nixosSystem {
        modules = [
          # YOUR OTHER MODULES
        ]
        ++ inputs.neovim.nixosModules.neovim;
      };
  };
}
```

### Keyboard Shortcuts

`<leader>` -> `<space>`

#### Base

| Shortcut           | Action                                  | Mode |
|--------------------|-----------------------------------------|------|
| `<leader>y`        | copy selected text to system clipboard  | v    |
| `<leader>p`        | paste selected text to system clipboard | v    |
| `<leader><leader>` | nohlsearch                              | n    |
| `<c-b>`            | previous buffer                         | n    |
| `<c-B>`            | next buffer                             | n    |
| `<c-left>`         | navigate left                           | n    |
| `<c-right>`        | navigate right                          | n    |
| `<c-up>`           | navigate up                             | t, n |
| `<c-down>`         | navigate down                           | n    |
| `<c-tab>`          | tabs to spaces                          | n    |
| `<c-t>`            | open terminal                           | n    |
| `<c-f>`            | format                                  | n, v |
| `<Esc>`            | normal mode                             | t, i |
| `<leader>e`        | ranger: open                            | n    |
| `<leader>E<left>`  | ranger: open left                       | n    |
| `<leader>E<down>`  | ranger: open down                       | n    |
| `<leader>E<up>`    | ranger: open up                         | n    |
| `<leader>E<right>` | ranger: open right                      | n    |
| `<leader>b`        | open buffers                            | n    |
| `<leader>f`        | find or fd on a path                    | n    |
| `<leader>F`        | opened files history                    | n    |
| `<leader>t`        | open tabs                               | n    |
| `<leader>T`        | search project tags                     | n    |
| `<leader>a`        | search all project lines                | n    |
| `<leader>A`        | search history                          | n    |
| `<leader>s`        | live grep current project               | n    |
| `<leader>S`        | live grep continue last search          | n    |
| `<leader>q`        | quickfix list                           | n    |
| `<leader>Q`        | quickfix history                        | n    |
| `<leader>l`        | location list                           | n    |
| `<leader>o`        | jumps                                   | n    |
| `<leader>"`        | registers                               | n    |
| `<leader>k`        | keymaps                                 | n    |
| `<leader>:`        | commands history                        | n    |
| `<leader>/`        | search history                          | n    |
| `<leader>'`        | marks                                   | n    |
| `<leader>?`        | code actions                            | n    |
| `<leader>c`        | git changes                             | n    |
| `<leader>gc`       | git commit log (project)                | n    |
| `<leader>gb`       | git commit log (buffer)                 | n    |
| `<leader>gt`       | git branches                            | n    |
| `<leader>gs`       | git status                              | n    |
| `<leader>gS`       | git stash                               | n    |
| `ga`               | go-to any LSP location (combined view)  | n    |
| `gd`               | go to definition                        | n    |
| `gD`               | go to declaration                       | n    |
| `gr`               | list references to symbol               | n    |
| `<leader>i`        | list symbol's implementations           | n    |
| `<leader>r`        | rename all references                   | n    |
| `<leader>h`        | show symbol info                        | n    |
| `<leader>H`        | show symbol signature                   | n    |
| `<leader>wa`       | add workspace folder                    | n    |
| `<leader>wl`       | list workspace folders                  | n    |
| `<leader>wd`       | remove workspace folder                 | n    |
| `<leader>ws`       | list symbols on workspace               | n    |
| `<leader>dd`       | open diagnostics float window           | n    |
| `<leader>db`       | open diagnostics buffer                 | n    |
| `<leader>ds`       | show diagnostics                        | n    |
| `<leader>dh`       | hide diagnostics                        | n    |
| `<leader>dn`       | get next diagnostic                     | n    |
| `<leader>dp`       | get previous diagnostic                 | n    |

#### Full

| Shortcut      | Action                                     | Mode |
|---------------|--------------------------------------------|------|
| `<leader>gg`  | Neogit                                     | n    |
| `<leader>gl`  | Neogit log                                 | n    |
| `<leader>gp`  | Neogit push                                | n    |
| `<leader>co`  | diffview: choose the OURS version          | n    |
| `<leader>ct`  | diffview: choose the THEIRS version        | n    |
| `<leader>cb`  | diffview: choose the BASE version          | n    |
| `<leader>ca`  | diffview: choose all versions              | n    |
| `<leader>gd`  | Diff view                                  | n    |
| `<leader>gD`  | Diff view master                           | n    |
| `<leader>db`  | Toggle breakpoint                          | n    |
| `<leader>dB`  | Set breakpoint                             | n    |
| `<leader>dr`  | Repl open                                  | n    |
| `<leader>dl`  | Run last                                   | n    |
| `<leader>dsl` | Set log loint message                      | n    |
| `<leader>dsc` | Set brealpoint condition                   | n    |
| `<leader>dn`  | Continue                                   | n    |
| `<leader>de`  | Step over                                  | n    |
| `<F3>`        | Step over                                  | n    |
| `<leader>di`  | Step into                                  | n    |
| `<F4>`        | Step into                                  | n    |
| `<leader>do`  | Step out                                   | n    |
| `<F5>`        | Step out                                   | n    |
| `<leader>duh` | Widgets (hover)                            | n    |
| `<leader>dup` | Widgets (preview)                          | n    |
| `<leader>duf` | Widgets Frames                             | n    |
| `<leader>dus` | Widgets Scopes                             | n    |
| `<leader>dui` | DAP UI toggle                              | n    |
| `<leader>dur` | DAP UI reset                               | n    |
| `<leader>due` | DAP UI eval                                | n    |
| `<leader>c`   | pick color                                 | n    |
| `<c-a>`       | spelunk: add to list                       | n    |
| `<c-s>`       | spelunk: toggle list                       | n    |
| `<c-h>`       | spelunk: next bookmark                     | n    |
| `<c-t>`       | spelunk: previous bookmark                 | n    |
| `<leader>A`   | toggle aerial                              | n    |
| `[[`          | aerial: next                               | n    |
| `]]`          | aerial: prev                               | n    |

## Messages

- On basic config: `:messages`
- On full config: `:NoiceAll`

## Example of how to add your own plugin

```nix
  nvim-focus = prev.vimUtils.buildVimPlugin {
    pname = "focus-nvim";
    version = "git";
    src = prev.fetchFromGitHub {
      owner = "nvim-focus";
      repo = "focus.nvim";
      rev = "31f41d91b6b331faa07f0a513adcbc37087d028d";
      sha256 = "sha256-IOMhyplEyLEPJ/oXFjOfs7uXY52AcVrSZuHV7t4NeUE=";
    };
  };
```
