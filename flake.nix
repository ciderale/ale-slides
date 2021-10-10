{
  description = "Flake for producing slides";

  outputs = { self, nixpkgs }: {

    overlay = final: prev: {
      ale-slides = final.callPackages ./default.nix {};
    };

  };
}
