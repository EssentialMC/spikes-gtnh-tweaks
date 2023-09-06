{
  azul-jdks = pkgs: pkgs0:
    let jdks = pkgs.callPackage ./azul { };
    in { inherit (jdks) zulu11 zulu17 zulu20; };
}
