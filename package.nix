# replyguy for Nix: the prebuilt app files from a release, run with nixpkgs' Electron.
# The installers bundle their own Electron, which can't run on NixOS; this one can, and so can
# the native messaging helper the browser starts (it reuses this Electron from the Nix store).
{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  electron,
  version,
  url,
  hash,
}:
stdenvNoCC.mkDerivation {
  pname = "replyguy";
  inherit version;
  src = fetchurl { inherit url hash; };
  sourceRoot = "replyguy";

  nativeBuildInputs = [ makeWrapper copyDesktopItems ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/replyguy
    cp -r . $out/share/replyguy/
    # REPLYGUY_NIX: updates come through the flake, so the app only says when a new one is out.
    makeWrapper ${lib.getExe electron} $out/bin/replyguy \
      --add-flags $out/share/replyguy \
      --set REPLYGUY_NIX 1
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "replyguy";
      exec = "replyguy";
      desktopName = "replyguy";
      comment = "Drafts X replies and posts in your voice";
      categories = [ "Utility" ];
    })
  ];

  meta = {
    description = "Drafts X replies and posts in your voice; you edit and post them";
    homepage = "https://github.com/swapnilraj/replyguy-releases";
    platforms = lib.platforms.linux;
    mainProgram = "replyguy";
  };
}
