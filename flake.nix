{
  description = "Neovim Config";

  outputs = { ... }: {
    nixosModules.neovim = [
      {
        imports = [ ./packages.nix ];
        nixpkgs.overlays = [
          (import ./overlays.nix)
        ];
      }
    ];
  };
}
