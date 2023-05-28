{ lib
, stdenv
, rustPlatform
, fetchFromGitLab
, meson
, ninja
, pkg-config
, wrapGAppsHook4
, gdk-pixbuf
, glib
, gtk4
, libadwaita
, libxml2
, openssl
, sqlite
, webkitgtk
, glib-networking
, librsvg
, gst_all_1
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "newsflash";
  version = "2.2.2";

  src = fetchFromGitLab {
    owner = "news-flash";
    repo = "news_flash_gtk";
    rev = "refs/tags/v.${finalAttrs.version}";
    sha256 = "sha256-QEfbuTJ0spp0g/XPoS0ZaqudSkWZtXMd3ZTzAHiv45Q=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    name = "${finalAttrs.pname}-${finalAttrs.version}";
    src = finalAttrs.src;
    sha256 = "sha256-AGsiB+xNSZzaG/PFgjKNKQopRUcyX27sLdyhT626Gcc=";
  };

  patches = [
    # Post install tries to generate an icon cache & update the
    # desktop database. The gtk setup hook drop-icon-theme-cache.sh
    # would strip out the icon cache and the desktop database wouldn't
    # be included in $out. They will generated by xdg.mime.enable &
    # gtk.iconCache.enable instead.
    ./no-post-install.patch
  ];

  postPatch = ''
    patchShebangs build-aux/cargo.sh
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4

    # Provides setup hook to fix "Unrecognized image file format"
    gdk-pixbuf

    # Provides glib-compile-resources to compile gresources
    glib
  ] ++ (with rustPlatform; [
    cargoSetupHook
    rust.cargo
    rust.rustc
  ]);

  buildInputs = [
    gtk4
    libadwaita
    libxml2
    openssl
    sqlite
    webkitgtk

    # TLS support for loading external content in webkitgtk WebView
    glib-networking

    # SVG support for gdk-pixbuf
    librsvg
  ] ++ (with gst_all_1; [
    # Audio & video support for webkitgtk WebView
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ]);

  meta = with lib; {
    description = "A modern feed reader designed for the GNOME desktop";
    homepage = "https://gitlab.com/news-flash/news_flash_gtk";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ kira-bruneau stunkymonkey ];
    platforms = platforms.unix;
    mainProgram = "com.gitlab.newsflash";
  };
})