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
