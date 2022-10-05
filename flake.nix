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
        ale-slides = final.callPackages ./default.nix {
          inherit revealJs;
          inherit (prev.nodePackages) browser-sync;
        };
        decktape = (import ./decktape {pkgs = final;}).nodeDependencies;
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlay];
      };
      decktape2nix = pkgs.writers.writeBashBin "decktap2nix" ''
        PATH=${with pkgs; lib.makeBinPath [nodejs-18_x node2nix coreutils bash]};
        mkdir decktape \
        && cd decktape \
        && npm init -y \
        && npm install decktape \
        && rm -r ./node_modules \
        && node2nix -18 -l package-lock.json \
        && echo "installed decktape" \
        && echo "add decktape to git"
      '';
    in {
      packages =
        {
          inherit decktape2nix;
          inherit (pkgs) decktape;
        }
        // pkgs.ale-slides;
      formatter = pkgs.alejandra;
    });
}
