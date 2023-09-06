{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
    nixfmt.url = "github:serokell/nixfmt";
  };

  outputs = inputs@{ self, nixpkgs, systems, nixfmt, ... }:
    let
      inherit (nixpkgs) lib;
      eachSystem = lib.genAttrs (import systems);
      pkgsFor = eachSystem (system:
        import nixpkgs {
          localSystem = system;
          overlays = [ self.overlays.azul-jdks ];
        });
    in {
      overlays = import ./nix/overlays.nix;

      packages =
        eachSystem (system: import ./nix/packages.nix pkgsFor.${system});

      devShells = eachSystem (system:
        let pkgs = pkgsFor.${system};
        in {
          default = pkgs.mkShell { nativeBuildInputs = [ pkgs.zulu17 ]; };
        });

      formatter = eachSystem (system: nixfmt.packages.${system}.default);
    };
}
