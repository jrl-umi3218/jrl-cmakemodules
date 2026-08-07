{
  description = "CMake utility toolbox";

  inputs.gepetto.url = "github:gepetto/nix";

  outputs =
    inputs:
    inputs.gepetto.lib.mkFlakoboros inputs (
      { lib, ... }:
      {
        overrideAttrs = {
          jrl-cmakemodules = {
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.gitTracked ./.;
            };
          };
          jrl-cmakemodules-scripts = { pkgs-final, drv-prev, ... }: {
            nativeBuildInputs = drv-prev.nativeBuildInputs ++ [
              pkgs-final.git
            ];
          };
        };
      }
    );
}
