{
  description = "A Nix-flake-based Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs
    , fenix
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        # you either want `stable` or `latest` (aka nightly)
        toolchain = fenix.packages."${system}".stable.toolchain;
        # <whatever>.toolchain will give you all the tools.
        # You can define more granularly (e.g. to use alternate targets)
        # by using combine like below:
        # toolchain = with fenix.packages."${system}";
        #   combine [
        #     latest.cargo
        #     latest.rustc
        #     targets.wasm32-unknown-unknown.latest.rust-std
        #   ];
        # See https://github.com/nix-community/fenix documentation
      in
      rec {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [
            toolchain
          ];
          buildInputs = with pkgs; [
            openssl
            lld
          ];
          packages = with pkgs; [ ];
          shellHook = ''
            export PATH=$PATH:''${CARGO_HOME:-~/.cargo}/bin
            export PATH=$PATH:''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
          '';
        };
      }
    );
}
