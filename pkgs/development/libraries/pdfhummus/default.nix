{ lib
, stdenv
, fetchFromGitHub
, cmake
, qtbase
, zlib
, freetype
, libjpeg
, libtiff
, libpng
}:

stdenv.mkDerivation rec {
  pname = "pdfhummus";
  version = "4.6.3";

  src = fetchFromGitHub {
    owner = "galkahana";
    repo = "PDF-Writer";
    rev = "v${version}";
    hash = "sha256-6Hp5hacMpVdsiUvMSXBQ5432tPrkHSOiVoWa91sv38k=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    qtbase
  ];

  propagatedBuildInputs = [
    zlib
    freetype
    libjpeg
    libtiff
    libpng
  ];

  dontWrapQtApps = true;

  cmakeFlags = [
    "-DUSE_BUNDLED=OFF"
    # Use bundled LibAesgm
    "-DUSE_UNBUNDLED_FALLBACK_BUNDLED=ON"
  ];

  meta = with lib; {
    description = "A Fast and Free C++ Library for Creating, Parsing an Manipulating PDF Files and Streams";
    homepage = "https://www.pdfhummus.com";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ rewine ];
  };
}

