{
  description = "Flake for producing slides";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {

    overlay = final: prev: {
      ale-slides = prev.pkgs.callPackages ./default.nix {
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
