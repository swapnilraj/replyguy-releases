{
  # Published to swapnilraj/replyguy-releases by the release workflow, next to release.json
  # (version, download link and hash of the app files). This copy is the template.
  description = "replyguy: drafts X replies and posts in your voice; you edit and post them";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      release = builtins.fromJSON (builtins.readFile ./release.json);
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAll (pkgs: rec {
        replyguy = pkgs.callPackage ./package.nix { inherit (release) version url hash; };
        default = replyguy;
      });
      homeManagerModules.default = import ./module.nix self;
    };
}
