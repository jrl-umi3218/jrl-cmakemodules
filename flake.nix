{
  description = "CMake utility toolbox";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { self, lib, ... }:
      {
        systems = lib.systems.flakeExposed;
        flake.overlays = {
          default = final: prev: {
            jrl-cmakemodules = prev.jrl-cmakemodules.overrideAttrs {
              src = lib.fileset.toSource {
                root = ./.;
                fileset = lib.fileset.gitTracked ./.;
              };
            };
          };
        };
        perSystem =
          {
            pkgs,
            self',
            system,
            ...
          }:
          {
            _module.args = {
              pkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [ self.overlays.default ];
              };
            };
            packages = {
              default = self'.packages.jrl-cmakemodules;
              jrl-cmakemodules = pkgs.jrl-cmakemodules;
            };
          };
      }
    );
}
