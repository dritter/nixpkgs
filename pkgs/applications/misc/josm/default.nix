{ lib, stdenv, fetchurl, fetchsvn, makeWrapper, unzip, jre, libXxf86vm
, extraJavaOpts ? "-Djosm.restart=true -Djava.net.useSystemProxies=true"
}:
let
  pname = "josm";
  versions = builtins.fromJSON (lib.readFile (./versions.json));
  version = versions.version;
  srcs = {
    jar = fetchurl {
      url = "https://josm.openstreetmap.de/download/josm-snapshot-${versions.version}.jar";
      hash = versions.linux.hash;
    };
    macosx = fetchurl {
      url = "https://josm.openstreetmap.de/download/macosx/josm-macos-${versions.version}-java17.zip";
      hash = versions.macosx.hash;
    };
    pkg = fetchsvn {
      url = "https://josm.openstreetmap.de/svn/trunk/native/linux/tested";
      rev = versions.version;
      sha256 = "sha256-/zdOaiyuvSwdVZcnw0ghDj2I+YKpFLc12fjZUMtRtVg=";
    };
  };
in
stdenv.mkDerivation rec {
  inherit pname version;

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = lib.optionals (!stdenv.isDarwin) [ jre ];

  installPhase =
    if stdenv.isDarwin then ''
      mkdir -p $out/Applications
      ${unzip}/bin/unzip ${srcs.macosx} 'JOSM.app/*' -d $out/Applications
    '' else ''
      install -Dm644 ${srcs.jar} $out/share/josm/josm.jar
      cp -R ${srcs.pkg}/usr/share $out

      # Add libXxf86vm to path because it is needed by at least Kendzi3D plugin
      makeWrapper ${jre}/bin/java $out/bin/josm \
        --add-flags "${extraJavaOpts} -jar $out/share/josm/josm.jar" \
        --prefix LD_LIBRARY_PATH ":" '${libXxf86vm}/lib'
    '';

  meta = with lib; {
    description = "An extensible editor for OpenStreetMap";
    homepage = "https://josm.openstreetmap.de/";
    changelog = "https://josm.openstreetmap.de/wiki/Changelog";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ rycee sikmir ];
    platforms = platforms.all;
  };
}
