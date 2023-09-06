{ version, openjdkVersion, hashes }:

{ stdenv, lib, fetchurl, autoPatchelfHook, unzip, makeWrapper, setJavaClassPath,
# minimum dependencies
alsa-lib, fontconfig, freetype, zlib, xorg,
# runtime dependencies
cups,
# runtime dependencies for GTK+ Look and Feel
gtkSupport ? stdenv.isLinux, cairo, glib, gtk3 }:

let
  platform = if stdenv.isDarwin then "macosx" else "linux";
  # Safe vecause this is `parseDoubleFromSystem` in `lib.systems.elaborate`.
  hash = hashes.${stdenv.hostPlatform.system};

  extension = if stdenv.isDarwin then "zip" else "tar.gz";
  architecture = if stdenv.isAarch64 then "aarch64" else "x64";

  runtimeDependencies = [ cups ]
    ++ lib.optionals gtkSupport [ cairo glib gtk3 ];
  runtimeLibraryPath = lib.makeLibraryPath runtimeDependencies;

in stdenv.mkDerivation (self: {
  inherit version platform hash extension;
  # Kept the name the same for compatibility with Nixpkgs derivations.
  openjdk = openjdkVersion;

  pname = "zulu";

  src = fetchurl {
    url =
      "https://cdn.azul.com/zulu/bin/zulu${version}-ca-jdk${openjdkVersion}-${platform}_${architecture}.${extension}";
    inherit hash;
  };

  buildInputs = lib.optionals stdenv.isLinux [
    alsa-lib # libasound.so wanted by lib/libjsound.so
    fontconfig
    freetype
    stdenv.cc.cc # libstdc++.so.6
    xorg.libX11
    xorg.libXext
    xorg.libXi
    xorg.libXrender
    xorg.libXtst
    zlib
  ];

  nativeBuildInputs = [ makeWrapper ]
    ++ lib.optionals stdenv.isLinux [ autoPatchelfHook ]
    ++ lib.optionals stdenv.isDarwin [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r ./* "$out/"
  '' + lib.optionalString stdenv.isLinux ''
    # jni.h expects jni_md.h to be in the header search path.
    ln -s $out/include/linux/*_md.h $out/include/
  '' + ''
    mkdir -p $out/nix-support
    printWords ${setJavaClassPath} > $out/nix-support/propagated-build-inputs

    # Set JAVA_HOME automatically.
    cat <<EOF >> $out/nix-support/setup-hook
    if [ -z "\''${JAVA_HOME-}" ]; then export JAVA_HOME=$out; fi
    EOF
  '' + lib.optionalString stdenv.isLinux ''
    # We cannot use -exec since wrapProgram is a function but not a command.
    #
    # jspawnhelper is executed from JVM, so it doesn't need to wrap it, and it
    # breaks building OpenJDK (#114495).
    for bin in $( find "$out" -executable -type f -not -name jspawnhelper ); do
      wrapProgram "$bin" --prefix LD_LIBRARY_PATH : "${runtimeLibraryPath}"
    done
  '' + ''
    runHook postInstall
  '';

  preFixup = ''
    find "$out" -name libfontmanager.so -exec \
      patchelf --add-needed libfontconfig.so {} \;
  '';

  passthru = { home = self.outPath; };

  meta = with lib; {
    homepage = "https://www.azul.com/products/zulu/";
    license = licenses.gpl2;
    description = "Certified builds of OpenJDK";
    longDescription = ''
      Certified builds of OpenJDK that can be deployed across multiple
      operating systems, containers, hypervisors and Cloud platforms.
    '';
    maintainers = with maintainers; [ spikespaz ];
    # Logic in topmost `let` block should reflect this.
    platforms = builtins.attrNames hashes;
    mainProgram = "java";
  };
})
