{
  description = "Flake for producing slides";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    revealJs.url = "github:hakimel/reveal.js";
    revealJs.flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    revealJs,
  }:
    {
      homeManagerModule = {pkgs, ...}: {
        nixpkgs.overlays = [self.overlay];
        home.packages = with pkgs.ale-slides; [
          slides-init
          slides-preview
          slides-build
        ];
      };

      overlay = final: prev: {
        ale-slides = prev.pkgs.callPackages ./default.nix {
          inherit revealJs;
          inherit (prev.nodePackages) browser-sync;
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlay];
      };
    in {
      packages = pkgs.ale-slides;
      formatter = pkgs.alejandra;
    });
}
