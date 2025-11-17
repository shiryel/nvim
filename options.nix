{ lib, pkgs, ... }:

{
  options.nix-neovim = {
    pkgs = lib.mkOption {
      default = pkgs;
    };
  };
}
