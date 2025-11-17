{
  description = "Neovim Config";

  outputs = { ... }: {
    nixosModules.neovim = [
      {
        imports = [
          ./options.nix
          ./packages
        ];
        nixpkgs.overlays = [
          (import ./overlays.nix)
        ];
      }
    ];
  };
}
