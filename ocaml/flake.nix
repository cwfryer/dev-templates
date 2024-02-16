{
  description = "A Nix-flake-based OCaml development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    opam-nix.url = "github:tweag/opam-nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    opam-nix,
    nixpkgs,
    flake-utils,
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      ocamlPackages = pkgs.ocamlPackages;
      on = opam-nix.lib.${system};

      # Put your project dependencies here.
      # "package" = "version"; where "package" = "*" chooses latest.
      devPackagesQuery = {
      };
      query =
        devPackagesQuery
        # If you need a certain ocaml version, put "ocaml-base-compiler" = "version" in here.
        // {};
      scope = on.buildOpamProject' {inherit pkgs;} ./. query;
      # Use this overlay to make changes to your packages
      overlay = final: prev: {
        # Example:
        # package = prev.package.overrideAttrs (_: {
        #   buildPhase = "dune build --release"
        #   See https://github.com/tweag/opam-nix/blob/main/DOCUMENTATION.md#package for more info
        # })
      };
      scope' = scope.overrideScope' overlay;
      devPackages =
        builtins.attrValues
        (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope');
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = devPackages;
        # Add any additional packages that you need here (e.g. ocamlformat)
        nativeBuildInputs = [];
      };
    });
}
