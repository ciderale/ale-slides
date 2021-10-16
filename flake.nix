{
  description = "Flake for producing slides";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    revealJs.url = "github:hakimel/reveal.js";
    revealJs.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, revealJs }: {

    overlay = final: prev: {
      ale-slides = prev.pkgs.callPackages ./default.nix {
        inherit revealJs;
        mkDerivation = prev.stdenv.mkDerivation;
        browser-sync = prev.nodePackages.browser-sync;
      };
    };

  } // flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs { inherit system; overlays = [self.overlay]; };
  in {

    packages = pkgs.ale-slides;

  });
}
