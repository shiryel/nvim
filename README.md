# Nixos Neovim Config

Configure with:
```nix
{
  inputs = {
    neovim.url = "github:shiryel/neovim/master";
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
