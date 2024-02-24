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
