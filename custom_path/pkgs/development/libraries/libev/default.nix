{ lib, stdenv, fetchurl
, # Note: -static hasn’t work on darwin
  static ? with stdenv.hostPlatform; isStatic && !isDarwin
}:

# Note: this package is used for bootstrapping fetchurl, and thus
# cannot use fetchpatch! All mutable patches (generated by GitHub or
# cgit) that are needed here should be included directly in Nixpkgs as
# files.

stdenv.mkDerivation rec {
  pname = "libev";
  version="4.33";

  src = fetchurl {
    url = "http://dist.schmorp.de/libev/Attic/${pname}-${version}.tar.gz";
    sha256 = "1sjs4324is7fp21an4aas2z4dwsvs6z4xwrmp72vwpq1s6wbfzjh";
  };

  configureFlags = lib.optional (static) "LDFLAGS=-static";

  meta = {
    description = "A high-performance event loop/event model with lots of features";
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.all;
    license = lib.licenses.bsd2; # or GPL2+
  };
}