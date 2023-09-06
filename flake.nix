{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
    nixfmt.url = "github:serokell/nixfmt";
  };

  outputs = inputs@{ nixpkgs, systems, nixfmt, ... }:
    let
      inherit (nixpkgs) lib;
      eachSystem = lib.genAttrs (import systems);
      pkgsFor = eachSystem (system: import nixpkgs { localSystem = system; });
    in {
      devShells = eachSystem (system:
        let pkgs = pkgsFor.${system};
        in {
          default =
            pkgs.mkShell { nativeBuildInputs = [ pkgs.temurin-17-bin ]; };
        });

      formatter = eachSystem (system: nixfmt.packages.${system}.default);
    };
}
