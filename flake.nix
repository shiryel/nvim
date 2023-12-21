{
  description = "Neovim Config";

  outputs = { ... }: {
    nixosModules.neovim = [
      {
        imports = [ ./packages.nix ];
        nixpkgs.hostPlatform = "x86_64-linux";
        nixpkgs.overlays = [
          (import ./overlays.nix)
        ];
      }
    ];
  };
}
