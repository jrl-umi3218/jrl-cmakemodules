{
  description = "CMake utility toolbox";

  inputs.gepetto.url = "github:gepetto/nix";

  outputs =
    inputs:
    inputs.gepetto.lib.mkFlakoboros inputs (
      { lib, ... }:
      {
        overrideAttrs.jrl-cmakemodules =
          { pkgs-final, ... }:
          {
            patches = [ ];
            cmakeFlags = [
              (lib.cmakeBool "JRL_CMAKEMODULES_GENERATE_API_DOC" true)
              (lib.cmakeBool "JRL_CMAKEMODULES_BUILD_TESTS" true)
            ];
            doCheck = true;
            checkInputs = [
              pkgs-final.catch2_3
              pkgs-final.matio
              pkgs-final.python3Packages.boost
              pkgs-final.python3Packages.nanobind
              pkgs-final.python3Packages.numpy
              pkgs-final.python3Packages.pytest
              pkgs-final.simde
              pkgs-final.suitesparse
            ];
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.gitTracked ./.;
            };
          };
      }
    );
}
